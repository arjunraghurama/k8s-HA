# Database Setup (MariaDB)

k3s supports pluggable external datastores. This setup uses **MariaDB** as the backend to store all cluster state, replacing the embedded `etcd`. This makes it possible to add or remove master nodes without migrating etcd data.

!!! info "Target Machine"
    Run these steps on the same dedicated infrastructure machine as the Nginx load balancer (e.g. `192.168.0.156`).

---

## Step 1 — Create the Docker Compose File

Create (or extend) a `docker-compose.yml` with the MariaDB and Adminer services:

```yaml title="docker-compose.yml"
services:

  db:
    image: mariadb
    restart: always
    environment:
      MARIADB_ROOT_PASSWORD: <insert_password_here>
      MARIADB_USER: dbuser
      MARIADB_PASSWORD: <insert_password_here>
      MARIADB_DATABASE: k3s
    ports:
      - 3306:3306
    volumes:
      - ./data:/var/lib/mysql:Z

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
```

!!! warning "Security"
    Replace `<insert_password_here>` with a strong, unique password. Avoid using the same password for both `MARIADB_ROOT_PASSWORD` and `MARIADB_PASSWORD` in production.

---

## Step 2 — Start the Database

```bash
docker compose up -d
```

Adminer (a lightweight DB UI) will be available at `http://192.168.0.156:8080`.

---

## Cleanup / Reset

If you need to wipe and restart the database from scratch:

```bash
docker compose down && rm -rf ./data/* && docker compose up -d
```

!!! danger "Data Loss"
    This command permanently deletes all cluster state stored in the database. Only run it if you intend to rebuild the cluster from scratch.

---

!!! tip "Next Step"
    Continue to [Master Node Setup](masters.md) to bootstrap the k3s control plane.
