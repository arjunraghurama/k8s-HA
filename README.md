# k8s-HA — High Availability Kubernetes Cluster

> A self-hosted **Highly Available (HA) Kubernetes cluster** built on **k3s**, designed to run on bare-metal or home-lab hardware with no single point of failure.

## Overview

This repository provides a complete, step-by-step guide for bootstrapping a **multi-master k3s cluster** with an external load balancer, a shared external database, and a bare-metal `LoadBalancer` implementation using MetalLB. The end result is a resilient cluster where the control plane remains available even if one master node goes down.

---
### Architecture
![Architecture Diagram](./assets/arch.drawio.svg)

### Key Components

| Component | Role |
|-----------|------|
| **k3s** | Lightweight, production-ready Kubernetes distribution |
| **Nginx (TCP stream)** | Layer-4 load balancer for the k8s API server (port 6443) |
| **MariaDB** | External datastore for k3s cluster state (replaces embedded etcd) |
| **MetalLB** | Bare-metal `LoadBalancer` implementation — assigns real IPs to `Service` objects |

### Why This Setup?

- **No cloud required** — runs entirely on your own hardware or home lab
- **Multi-master control plane** — k3s API server stays up if one master node fails
- **External datastore** — MariaDB decouples cluster state from individual nodes, making it easy to add more masters later
- **Real load balancer IPs** — MetalLB lets services get externally routable IPs without a cloud provider

### Prerequisites

- A machine to host the **Nginx load balancer** and **MariaDB** (e.g. `192.168.0.156`)
- At least **2 machines** for k3s master nodes
- At least **3 machines** for k3s worker nodes
- A local subnet with free IP addresses for MetalLB to assign (e.g. `192.168.0.170–192.168.0.175`)

---

## LoadBalancer for k8s

Create a nginx config file `nginx.conf` <br>
`192.168.0.151` and `192.168.0.152` are the IP of the k8s Master nodes

```nginx
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

Create nginx docker container

```docker
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


## Create a DB for k8s

```docker
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

For cleanup of DB
```bash
docker compose down && rm -rf ./data/* && docker compose up -d
```


## k8s - Master - 1
IP of  the machine where the nginx and DB are located `192.168.0.156` 
```bash
export K3S_DATASTORE_ENDPOINT='mysql://dbuser:<insert_password_here>@tcp(192.168.0.156:3306)/k3s'

curl -sfL https://get.k3s.io | sh -s - server \
--disable servicelb \
--node-taint CriticalAddonsOnly=true:NoExecute \
--tls-san 192.168.0.156

sudo k3s kubectl get nodes

sudo cat /var/lib/rancher/k3s/server/node-token
```

## k8s - Master - 2
```bash
export K3S_DATASTORE_ENDPOINT='mysql://dbuser:<insert_password_here>@tcp(192.168.0.156:3306)/k3s'

curl -sfL https://get.k3s.io | sh -s - server --token=<token-goes-here> \
--node-taint CriticalAddonsOnly=true:NoExecute \
--tls-san 192.168.0.156 --disable servicelb
```


## k8s - Worker - 1
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```


## k8s - Worker - 2
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```


## k8s - Worker - 3
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```


## Install metallb
On the Master node run the following commands
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
```

Create config file `metallb-config.yaml` as shown below. <br>
Choose a free IP pool range available from the router
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: external-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.170-192.168.0.175
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
```

Apply the config
```bash
sudo kubectl apply -f metallb-config.yaml
```



## Create a pod and service to test the setup

Create a test service with a pod `nginx-svc.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
---    
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

```
sudo kubectl apply -f nginx-svc.yaml
```

```
sudo kubectl get svc -o wide
```