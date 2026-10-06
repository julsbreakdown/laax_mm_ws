---
name: mm-community
description: Use when getting the Mergin Maps Community Edition (CE) server running on a laptop from this workshop repo, or when it fails to start. Triggers on "Mergin Maps CE", "mergin server", "get the workshop server running", "start the stack", ".prod.env", "flask init", errors from make up / make init / make check, a 502 or blank page on http://localhost:8080.
---

# Mergin Maps CE on a laptop

Goal: seven containers `Up`, admin created, `make check` clean, http://localhost:8080 answers.

Run `make` targets from the repo root. All of them use compose project `laax`. Never mix them with bare `docker compose` run from `docker/` (project `docker`): two stacks fight over the same container names.

No `Makefile` (student clone, it is gitignored)? Run the bare equivalents from `docker/`, as the decks do:

| make | from `docker/` |
|---|---|
| `make dirs` | `sh ../common/set_permissions.sh projects` and `... diagnostic_logs` (sudo) |
| `make up` | `docker compose up -d` |
| `make init EMAIL=...` | `docker compose exec server flask init -e ...` |
| `make check` | `docker compose exec server flask server check` |
| `make status` / `make logs` | `docker compose ps` / `docker compose logs -f server celery-worker` |

## 1. Prerequisites

Run each; stop and tell the user what to install if one fails.

```sh
git --version
docker --version
docker compose version
docker ps
openssl version
```

- `docker ps` must work without `sudo`. Permission denied: user not in the `docker` group (`sudo usermod -aG docker $USER`, then log out and in). Do not work around it with sudo.
- Windows: must be the Ubuntu WSL terminal, repo under `~`, never `/mnt/c/...` (`pwd` tells).
- `ss -ltn | grep ':8080 '` must print nothing, otherwise port 8080 is taken.

## 2. `.prod.env`

If `docker/.prod.env` already exists, do not overwrite it: check it (step end) and move on. Otherwise:

```sh
cd docker
cp .env.template .prod.env
sed -i \
  -e "s|^MERGIN_BASE_URL=.*|MERGIN_BASE_URL=http://localhost:8080|" \
  -e "s|^SECRET_KEY=.*|SECRET_KEY=$(openssl rand -hex 32)|" \
  -e "s|^SECURITY_PASSWORD_SALT=.*|SECURITY_PASSWORD_SALT=$(openssl rand -hex 32)|" \
  -e "s|^MAIL_SUPPRESS_SEND=.*|MAIL_SUPPRESS_SEND=1|" \
  -e "s|^CONTACT_EMAIL=.*|CONTACT_EMAIL=owner@example.com|" \
  -e "s|^#DB_DATABASE=mergin|DB_DATABASE=mergin|" \
  .prod.env
cd ..
```

Check: six lines, none `fixme`, base URL exactly `http://localhost:8080`.

```sh
grep -E '^(MERGIN_BASE_URL|SECRET_KEY|SECURITY_PASSWORD_SALT|MAIL_SUPPRESS_SEND|CONTACT_EMAIL|DB_DATABASE)=' docker/.prod.env
```

## 3. Start

```sh
make up
make status
```

`make up` runs `make dirs` first (projects/ and diagnostic_logs/ owned by 901:999). First run pulls about 1.5 GB. Expect seven containers `Up`. Wait for the server before init:

```sh
until curl -sf http://localhost:8080/ping >/dev/null; do sleep 3; done
curl -s http://localhost:8080/ping | head -c 80; echo
```

Must start with `{"base_url": "v1"`. Before init, `relation "user" does not exist` in the logs is expected.

## 4. Init, check, users

```sh
make init EMAIL=owner@example.com
```

Show the user the printed password: it appears once. Username is the email local part (`owner`); `admin@...` gives `admin0`. No password printed means the database was not empty: do not run `init -r` on a used server.

```sh
make check
```

Expect base URL `http://localhost:8080`, database, `/data` permissions and Celery all OK. `Mergin Maps version: 2025.6.2` is normal for image `2025.7.3`.

Optional, workshop accounts from `workshop/users.csv`: `make users`. "Already exists" lines are harmless.

## 5. Done when

```sh
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8080
```

prints `200`, and the user can log in at http://localhost:8080 as `owner`.

## Failures

`C` is the Makefile's compose command: `C="docker compose -p laax -f docker/docker-compose.yml --project-directory docker"`, run from the repo root.

| Symptom | Fix |
|---|---|
| `env file .prod.env not found` | step 2 |
| `port is already allocated` on 8080 | stop the other service, or change the proxy port in compose and `MERGIN_BASE_URL` |
| `error mounting .../common/nginx.conf ... not a directory` | Docker made `nginx.conf` a folder: remove it, restore `common/` with `git checkout common` |
| permission denied on `/data`, red permissions line in `make check` | `make dirs`, then `make restart` |
| HTTP 502 after a server container was recreated | `$C restart proxy` |
| redis restarting, `Can't handle RDB format version 11` | another stack's redis volume reused: `$C rm -sfv redis && make up` |
| `container name "/merginmaps-redis" is already in use` | another Mergin stack runs: `docker rename merginmaps-redis old_redis` or stop it |
| login 500, `relation "user" does not exist` | `make init` not run |
| "Server not properly configured" | `MERGIN_BASE_URL` still `fixme`: fix `.prod.env`, `make up` |
| lost admin password | `$C exec server flask user create owner2 <pw> --is-admin --email ...` |

After any `.prod.env` edit: `make up` recreates only what changed; if the server was recreated, restart the proxy too.

Start over (destroys all data, ask first): `make clean`, then steps 3 and 4.
