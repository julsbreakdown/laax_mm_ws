# DB Sync stack (module 07)

Two-way sync between the GeoPackage `data.gpkg` of `mergin/laax-survey` and a PostGIS schema, with `lutraconsulting/mergin-db-sync:2.3.0`.

| Container | Image | Reachable as |
|---|---|---|
| `laax-postgis` | `postgis/postgis:16-3.4` | `laax-postgis:5432` on network `mergin`, `localhost:5433` from the laptop |
| `laax-dbsync` | `lutraconsulting/mergin-db-sync:2.3.0` | no port, talks to `http://merginmaps-proxy:8080` |

Both join the external network `mergin` created by the server stack, so the server stack must be up first.

## Prerequisites

- `mergin/laax-survey` exists on the server and contains `data.gpkg`.
- The account in `config.yaml` can write to that project.
- Schemas `survey` and `survey_base` do not exist in PostGIS.

## Commands

From `~/workshop_mm_laax/laax/dbsync`:

```sh
cp config.yaml.template config.yaml      # then set the owner password
docker compose up -d postgis
docker compose run --rm dbsync /config/config.yaml --single-run   # init + one pass
docker compose up -d dbsync                                        # daemon, every 10 s
docker compose logs -f dbsync
```

Check:

```sh
docker compose exec postgis psql -U dbsync -d dbsync -c '\dt survey.*'
docker compose exec postgis psql -U dbsync -d dbsync -c 'select count(*) from survey.observations'
```

Restart the sync from scratch (schema change in the GeoPackage, broken base schema):

```sh
docker compose stop dbsync
docker compose run --rm dbsync /config/config.yaml --force-init --single-run
docker compose up -d dbsync
```

Stop, keep data: `docker compose down`. Wipe PostGIS and the db-sync working copy: `docker compose down -v`.

QGIS on the laptop: PostgreSQL connection, host `localhost`, port `5433`, database `dbsync`, user and password `dbsync`. Edit `survey.observations`, never `survey_base`.
