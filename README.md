# AJA Digital Full

Ambiente local com dois submódulos Git em `frontend/` e `backend/`. O Compose usa o frontend estático, o gateway existente, Core, Questions, Email, PostgreSQL, RabbitMQ e Mailpit. A primeira subida carrega dados fictícios de demonstração.

Clone o repositório com os submódulos:

~~~
git clone --recurse-submodules https://github.com/joao-0213/aja-digital-full.git
cd aja-digital-full
~~~

Com Docker Desktop em execução, abra um terminal nesta pasta e rode:

~~~
docker compose up --build --wait
~~~

| Serviço | Endereço |
| --- | --- |
| Frontend | [http://127.0.0.1:3000](http://127.0.0.1:3000) |
| API | [http://127.0.0.1:3002/api/v1/health](http://127.0.0.1:3002/api/v1/health) |
| Mailpit (modo de teste) | [http://127.0.0.1:8025](http://127.0.0.1:8025) |

Acesse o frontend como administrador com admin@aja.local.test e a senha de demonstração AjaDemo-2026!. As outras contas estão no [guia do backend](backend/docs/backend/local-development.md).

Use 127.0.0.1 para abrir o frontend. O navegador usa esse mesmo host na API para enviar o cookie de sessão. Os valores de backend/env.integrated.example são exclusivos do ambiente local.

## Atualizar os projetos

Na raiz do Full, atualize o repositório, sincronize os submódulos com os commits registrados e reconstrua as imagens:

~~~
git pull --ff-only
git submodule update --init --recursive
docker compose up --build --wait
~~~

## E-mail

O arquivo local .env ativa o Resend com o remetente do AJA. Mantenha esse arquivo fora de cópias compartilhadas. Os links de confirmação e recuperação apontam para o frontend desta máquina.

Para capturar e-mails no Mailpit durante um teste, altere o modo do worker com:

~~~
docker compose --env-file backend/env.integrated.example up --wait email
~~~

Restaure o Resend com:

~~~
docker compose up --wait email
~~~

## Produção em ajadigital.com.br

Um push na `main` deste repositório publica na VPS os commits de frontend e backend registrados nos submódulos. Depois de um push em um submódulo, publique também a atualização da referência no Full.

Na VPS Linux, use Docker Engine com o plugin Compose 2.24.4 ou superior. Clone este repositório em `/opt/aja-digital`, com acesso de escrita e ao Docker para o usuário `aja-deploy`. Instale `deploy/deploy.sh` em `/usr/local/bin/aja-deploy`, com permissões de execução e dono `root`. No `authorized_keys` de `aja-deploy`, adicione a chave pública dedicada com o prefixo `restrict,command="/usr/local/bin/aja-deploy"`.

Crie `/opt/aja-digital/.env` com permissão `0600` para o usuário de deploy. Use os nomes de variáveis de `backend/env.integrated.example`, com senhas e tokens gerados para produção. Para `CORE_OUTBOX_ENCRYPTION_KEY`, use `openssl rand -base64 32`. Preserve essa chave e as senhas entre deploys. Configure `EMAIL_PROVIDER_TOKEN` com a chave do Resend e `EMAIL_PROVIDER_FROM` com o remetente verificado.

No GitHub, configure os secrets `VPS_SSH_KEY` com a chave privada de deploy e `VPS_KNOWN_HOSTS` com a entrada SSH verificada da VPS. Defina a variável `VPS_HOST` com o endereço da VPS e, se necessário, `VPS_PORT` com a porta SSH. A variável `VPS_HOST` habilita a etapa de publicação.

Aponte o registro DNS `A` de `ajadigital.com.br` para o IPv4 da VPS e libere as portas TCP 80 e 443. O Caddy emite e renova o certificado. O workflow verifica o frontend e `/api/v1/health` por HTTPS após a publicação. PostgreSQL, RabbitMQ e os certificados usam volumes persistentes. [Documentação de HTTPS automático do Caddy](https://caddyserver.com/docs/automatic-https)

## Parar o ambiente

Para parar os contêineres preservando o banco:

~~~
docker compose down
~~~
