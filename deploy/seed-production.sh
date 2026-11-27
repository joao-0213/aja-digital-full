#!/bin/sh
set -eu

for hash in "$DEMO_ADMIN_PASSWORD_HASH" "$DEMO_TEACHER_PASSWORD_HASH" "$DEMO_STUDENT_PASSWORD_HASH"; do
  if ! printf '%s\n' "$hash" | grep -Eq '^\$argon2id\$v=19\$m=16384,t=2,p=1\$[A-Za-z0-9+/]{22}\$[A-Za-z0-9+/]{43}$'; then
    echo 'Invalid demonstration password hash.' >&2
    exit 1
  fi
done

mkdir -p /opt/aja/demo
cp -R /opt/aja/demo-source/. /opt/aja/demo/

# Assign the deployment passwords inside the existing seed transaction.
awk -v admin="$DEMO_ADMIN_PASSWORD_HASH" -v teacher="$DEMO_TEACHER_PASSWORD_HASH" -v student="$DEMO_STUDENT_PASSWORD_HASH" '
  /^INSERT INTO core[.]demo_seed_state[(]/ {
    print "UPDATE core.users SET password_hash = CASE role"
    printf "  WHEN \047admin\047 THEN \047%s\047\n", admin
    printf "  WHEN \047teacher\047 THEN \047%s\047\n", teacher
    printf "  ELSE \047%s\047 END\n", student
    print "WHERE id LIKE \047demo-%\047 AND normalized_email LIKE \047%@aja.local.test\047;"
    inserted++
  }
  { print }
  END { if (inserted != 1) exit 1 }
' /opt/aja/demo-source/core.sql > /opt/aja/demo/core.sql

exec sh /opt/aja/demo/seed.sh
