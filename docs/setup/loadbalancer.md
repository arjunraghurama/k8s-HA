# Load Balancer Setup (Nginx)

The Nginx load balancer distributes incoming API server traffic across all k3s master nodes at **Layer 4 (TCP)**. This is the single entry point for both external tools (`kubectl`) and worker nodes joining the cluster.

!!! info "Target Machine"
    Run these steps on the dedicated infrastructure machine — the one that will also host the MariaDB database (e.g. `192.168.0.156`).

---

## Step 1 — Create the Nginx Config

Create a file named `nginx.conf` with the following content.

> Replace `192.168.0.151` and `192.168.0.152` with the actual IPs of your k3s master nodes.

```nginx title="nginx.conf"
events {}

stream {
  upstream k3s_servers {
    server 192.168.0.151:6443;
    server 192.168.0.152:6443;
  }

  server {
    listen 6443;
    proxy_pass k3s_servers;
  }
}
```

---

## Step 2 — Create the Docker Compose File

Create a `docker-compose.yml` (or add to an existing one) with the Nginx service:

```yaml title="docker-compose.yml"
services:
  nginx-lb:
    image: nginx:latest
    container_name: nginx-lb
    restart: always
    ports:
      - "6443:6443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

---

## Step 3 — Start the Load Balancer

```bash
docker compose up -d
```

---

## Verification

Confirm the container is running:

```bash
docker ps | grep nginx-lb
```

You should see `nginx-lb` in the output. Workers and `kubectl` clients should now point to `192.168.0.156:6443`.

---

!!! tip "Next Step"
    Continue to [Database Setup](database.md) to deploy MariaDB.
