## Running telemetry stack

To run telemetry stack, run 
```
cd deployment/common/telemetry
docker compose -f docker-compose.otel.yml up -d
```

If you want to use your own opentelemetry collector you need to modify variables in .otel.env which are used in merginmaps server and celery workers.

Grafana UI is accesible on port 3000 but it can be exposed via mergin nginx proxy (uncomment in nginx.conf).

## Workshop additions

- `otel-config.yaml`: `docker_stats` receiver, container CPU and memory into Prometheus. The collector runs as root and mounts the Docker socket for it.
- `grafana-dashboards.yaml` and `grafana-dashboards/containers.json`: provisioned dashboard **Containers**.
