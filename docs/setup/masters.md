# Master Node Setup

The k3s master nodes form the **control plane** of your HA cluster. With multiple masters all pointing to the same external MariaDB datastore, the cluster remains available even when one master is offline.

!!! note "Prerequisites"
    - Nginx load balancer is running on `192.168.0.156:6443`
    - MariaDB is running and accessible on `192.168.0.156:3306`
    - All master node machines are reachable on your local network

---

## Master 1 (Bootstrap Node)

The first master bootstraps the cluster and generates the shared **node token** that all subsequent nodes use to join.

```bash title="Master 1 — Bootstrap"
export K3S_DATASTORE_ENDPOINT='mysql://dbuser:<insert_password_here>@tcp(192.168.0.156:3306)/k3s'

curl -sfL https://get.k3s.io | sh -s - server \
--disable servicelb \
--node-taint CriticalAddonsOnly=true:NoExecute \
--tls-san 192.168.0.156
```

**Key flags explained:**

| Flag | Purpose |
|------|---------|
| `--disable servicelb` | Disables the built-in ServiceLB so MetalLB can manage LoadBalancer IPs |
| `--node-taint CriticalAddonsOnly=true:NoExecute` | Prevents workloads from being scheduled on master nodes |
| `--tls-san 192.168.0.156` | Adds the load balancer IP to the TLS certificate SAN so `kubectl` works through it |

### Verify the Node

```bash
sudo k3s kubectl get nodes
```

### Retrieve the Node Token

You'll need this token for all subsequent master and worker nodes:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

!!! warning "Keep this token safe"
    Copy this token and store it securely. You'll need it to join every other node to the cluster.

---

## Master 2

Replace `<token-goes-here>` with the token retrieved from Master 1.

```bash title="Master 2 — Join"
export K3S_DATASTORE_ENDPOINT='mysql://dbuser:<insert_password_here>@tcp(192.168.0.156:3306)/k3s'

curl -sfL https://get.k3s.io | sh -s - server --token=<token-goes-here> \
--node-taint CriticalAddonsOnly=true:NoExecute \
--tls-san 192.168.0.156 --disable servicelb
```

After this node joins, verify it appears:

```bash
sudo k3s kubectl get nodes
```

---

!!! tip "Adding More Masters"
    To add more master nodes in the future, simply repeat the **Master 2** steps on each new machine.

!!! tip "Next Step"
    Continue to [Worker Node Setup](workers.md) to join worker nodes to the cluster.
