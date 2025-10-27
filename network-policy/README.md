# 🛡️ NetworkPolicy — Kubernetes Deep Dive

## 📘 Overview
A **NetworkPolicy** in Kubernetes defines how Pods are allowed to communicate with each other and other network endpoints.  
By default, **all Pods can talk to all other Pods** across namespaces unless a `NetworkPolicy` is applied.

When used correctly, NetworkPolicies enforce a **“least privilege”** or **zero-trust** network model, where only explicitly allowed communication is permitted.

---

## 🔁 How It Fits in the Cluster Lifecycle
- Pods start **fully open** by default.
- Once a `NetworkPolicy` is created, only traffic explicitly permitted by that policy is allowed.
- Policies are **namespace-scoped**, meaning they only affect Pods within that namespace.
- Implementation depends on your **CNI plugin** (e.g., Calico, Cilium, Weave, Kube-Router).

---

## 🧠 Important Note for Kind Users

> ⚠️ **Kind (Kubernetes in Docker)** does *not* enforce NetworkPolicies by default.  
> This is because the default Kind networking (based on `bridge`) doesn’t use a NetworkPolicy-aware CNI.

### ✅ To test NetworkPolicies in Kind, install a compatible CNI:
#### Option 1: Calico (recommended)
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

#### Option 2: Cilium
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.15/install/kubernetes/quick-install.yaml
```

Once the CNI pods are running (`kubectl get pods -n kube-system`), NetworkPolicies will start taking effect.

---

## ⚙️ Core CLI Reference

| Action | Command |
|--------|----------|
| Apply | `kubectl apply -f networkpolicy.yaml` |
| List all | `kubectl get networkpolicy -A` |
| Describe | `kubectl describe networkpolicy <name>` |
| Delete | `kubectl delete networkpolicy <name>` |

---

## 🧩 YAML Example: Deny-All + Allow-From-App Policy

Below is a production-style example demonstrating a **default deny** followed by a **specific allow rule**.

Save as: `networkpolicy.yaml`

```yaml
# NetworkPolicy Example
# Purpose: Deny all ingress by default, then allow only traffic from app pods.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-restrict-policy
  namespace: production
spec:
  # Target pods labeled with 'role=db'
  podSelector:
    matchLabels:
      role: db

  # Define policy types
  policyTypes:
  - Ingress
  - Egress

  # Allow ingress only from Pods labeled 'role=app'
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: app
    ports:
    - protocol: TCP
      port: 3306  # MySQL port

  # Allow egress only to external API services
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 443  # HTTPS
```

---

## 🧭 Best Practices
✅ Always start with a **default deny-all** policy (`podSelector: {}` with no `ingress` or `egress`).  
✅ Layer specific allow policies incrementally to avoid accidental outages.  
✅ Label Pods consistently (e.g., `tier=frontend`, `role=db`).  
✅ Keep policies modular per namespace or app component.  
✅ Verify reachability using `kubectl exec` with `curl` or `nc` (netcat).

---

## 🧰 Troubleshooting Checklist
- [ ] Is the **CNI plugin** installed and NetworkPolicy-aware?  
  Use: `kubectl get pods -n kube-system`  
- [ ] Is the policy applied to the **correct namespace**?  
  Use: `kubectl get networkpolicy -n <ns>`  
- [ ] Do the **Pod labels** match your `podSelector`?  
  Use: `kubectl get pods -n <ns> --show-labels`  
- [ ] Check **CNI logs** (e.g., Calico):  
  ```bash
  kubectl logs -n kube-system -l k8s-app=calico-node
  ```
- [ ] Validate policy effects:  
  ```bash
  kubectl exec -it <pod> -- curl <target-pod-ip>:<port>
  ```

---

## 🌐 Reference Links
- [Kubernetes Docs — Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Project Calico Documentation](https://projectcalico.docs.tigera.io/about/about-network-policy)
- [Cilium Network Policy Guide](https://docs.cilium.io/en/stable/policy/)
- [Kind Installation Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)
