# MetalLB Setup

In a standard cloud Kubernetes setup, creating a `Service` of type `LoadBalancer` automatically provisions a cloud load balancer with a public IP. On bare-metal, no such mechanism exists out of the box. **MetalLB** fills this gap by assigning real IP addresses from your local subnet to `LoadBalancer` services.

!!! note "Prerequisites"
    - All master and worker nodes are up and joined to the cluster
    - You have a range of **free IP addresses** on your local subnet (not assigned by DHCP)
    - Commands are run from a master node

---

## Step 1 — Install MetalLB

Apply the official MetalLB manifest from a master node:

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
```

This creates the `metallb-system` namespace and deploys the MetalLB controllers.

---

## Step 2 — Configure an IP Address Pool

Create a file named `metallb-config.yaml`. Choose a free IP range from your router's subnet that **is not part of the DHCP pool**.

```yaml title="metallb-config.yaml"
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

!!! warning "Choose your IP range carefully"
    IPs in the pool (e.g. `192.168.0.170–192.168.0.175`) must **not** be assigned by your router's DHCP server, otherwise you'll get IP conflicts. Reserve them in your router's DHCP settings if possible.

---

## Step 3 — Apply the Configuration

```bash
sudo kubectl apply -f metallb-config.yaml
```

---

## Verification

After applying, any `Service` of type `LoadBalancer` will automatically get an IP from the pool:

```bash
sudo kubectl get svc -o wide
```

You should see an `EXTERNAL-IP` assigned from your configured range (e.g. `192.168.0.170`).

---

!!! tip "Next Step"
    Validate your full setup by deploying a [test pod and service](testing.md).
