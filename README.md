# k8s-HA — High Availability Kubernetes Cluster

> A self-hosted **Highly Available (HA) Kubernetes cluster** built on **k3s**, designed to run on bare-metal or home-lab hardware.

## Overview

This repository provides a complete, step-by-step guide for bootstrapping a **multi-master k3s cluster** with an external load balancer, a shared external database, and a bare-metal `LoadBalancer` implementation using MetalLB. The end result is a resilient cluster where the control plane remains available even if one master node goes down.

---
### Architecture
![Architecture Diagram](./docs/assets/arch.drawio.svg)

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

## Documentation

For the complete, step-by-step setup guide and detailed documentation, please visit our **[Documentation Site](https://arjunraghurama.github.io/k8s-HA/)**.