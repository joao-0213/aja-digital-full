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

## Parar o ambiente

Para parar os contêineres preservando o banco:

~~~
docker compose down
~~~
