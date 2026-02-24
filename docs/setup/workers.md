# Worker Node Setup

Worker nodes run your actual workloads (pods). They join the cluster by connecting through the Nginx load balancer, which routes to whichever master is available.

!!! note "Prerequisites"
    - At least one master node is up and running
    - You have the **node token** from Master 1 (`/var/lib/rancher/k3s/server/node-token`)
    - The Nginx load balancer is reachable at `192.168.0.156:6443`

---

## Joining a Worker Node

Run the following command on **each worker machine**. Replace `<token-goes-here>` with the token from Master 1.

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```

This single command:

1. Downloads and installs the k3s agent
2. Registers the worker with the cluster via the load balancer
3. Starts the agent as a systemd service

---

## Worker 1

```bash title="Worker 1"
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```

---

## Worker 2

```bash title="Worker 2"
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```

---

## Worker 3

```bash title="Worker 3"
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.156:6443 K3S_TOKEN=<token-goes-here> sh -
```

---

## Verify All Nodes

From any master node, confirm all workers appear in the node list:

```bash
sudo k3s kubectl get nodes -o wide
```

You should see all master and worker nodes listed with status `Ready`.

---

!!! tip "Adding More Workers"
    To scale the cluster, simply run the join command on any additional machines. No changes to the master nodes are needed.

!!! tip "Next Step"
    Continue to [MetalLB Setup](metallb.md) to configure bare-metal LoadBalancer IP assignment.
