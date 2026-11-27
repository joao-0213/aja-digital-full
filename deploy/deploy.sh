#!/usr/bin/env bash
set -euo pipefail

revision=${SSH_ORIGINAL_COMMAND:-${1:-}}
if [[ ! "$revision" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Informe o SHA completo de um commit da main." >&2
  exit 2
fi

cd /opt/aja-digital
exec 9>.git/aja-deploy.lock
flock 9
test -s .env
for name in POSTGRES_USER POSTGRES_PASSWORD CORE_DATABASE_PASSWORD QUESTIONS_DATABASE_PASSWORD \
  EMAIL_DATABASE_PASSWORD RABBITMQ_USER RABBITMQ_PASSWORD CORE_OUTBOX_ENCRYPTION_KEY \
  CORE_OUTBOX_OPERATOR_TOKEN EMAIL_DELIVERY_OPERATOR_TOKEN CORE_QUESTIONS_SERVICE_TOKEN \
  EMAIL_PROVIDER_TOKEN EMAIL_PROVIDER_FROM; do
  if ! grep -Eq "^${name}=.+" .env; then
    echo "Configure ${name} no .env de produção." >&2
    exit 1
  fi
done

git fetch origin main
if [[ "$revision" != "$(git rev-parse FETCH_HEAD)" ]]; then
  echo "Commit supersedido pelo estado atual da main."
  exit 0
fi

git checkout --detach "$revision"
git submodule sync --recursive
git submodule update --init --recursive

compose=(docker compose --env-file .env -f compose.yaml -f compose.production.yaml)
"${compose[@]}" config --quiet
"${compose[@]}" run --rm --no-deps caddy caddy validate --config /etc/caddy/Caddyfile
"${compose[@]}" --parallel 1 build
"${compose[@]}" up -d --no-build --wait --wait-timeout 480
"${compose[@]}" exec -T caddy caddy reload --config /etc/caddy/Caddyfile
