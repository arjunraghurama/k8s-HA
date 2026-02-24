# Testing the Setup

Now that all components are in place, let's validate the full end-to-end setup by deploying a simple **nginx pod** exposed via a `LoadBalancer` service. If MetalLB assigns an external IP and the pod is reachable, your HA cluster is working correctly.

---

## Step 1 — Create the Test Manifest

Create a file named `nginx-svc.yaml`:

```yaml title="nginx-svc.yaml"
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

---

## Step 2 — Apply the Manifest

```bash
sudo kubectl apply -f nginx-svc.yaml
```

---

## Step 3 — Check the Service

```bash
sudo kubectl get svc -o wide
```

Expected output (when MetalLB assigns an IP):

```
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
nginx-service   LoadBalancer   10.43.x.x       192.168.0.170    80:3xxxx/TCP   30s
```

!!! success "It's working!"
    If you see an `EXTERNAL-IP` from your MetalLB pool (e.g. `192.168.0.170`), your cluster is fully operational. Try visiting `http://192.168.0.170` from any device on your network — you should see the default Nginx welcome page.

---

## Troubleshooting

| Issue | Possible Cause | Fix |
|-------|---------------|-----|
| `EXTERNAL-IP` is `<pending>` | MetalLB not configured or pod not ready | Check `kubectl get pods -n metallb-system` |
| Cannot reach the IP from browser | IP conflict or firewall | Verify the IP range is free; check `iptables` rules |
| Pod in `Pending` state | No worker nodes schedulable | Check `kubectl get nodes` — workers must be `Ready` |

---

## Cleanup

To remove the test resources:

```bash
sudo kubectl delete -f nginx-svc.yaml
```

---

!!! tip "What's next?"
    Your HA k3s cluster is ready. You can now deploy real workloads using Helm charts, Kustomize, or plain manifests. All `LoadBalancer` services will automatically receive IPs from your MetalLB pool.
