# ⚙️ Implementing Taints, Tolerations & Node Affinity in the Demo Setup

This guide explains how to extend the existing **k8s-realtime-demo** environment to control **Pod scheduling** using **taints**, **tolerations**, and **node affinity**.  
We’ll use the already existing `demo` namespace and resources.

---

## 🧠 What We’re Doing
You’ll:
1. Apply a **taint** to one node.
2. Add a **toleration** in the Deployment (already present in YAML).
3. Label the node for **node affinity** to match.
4. Verify that Pods from `demo-deployment` run **only on the targeted node**.

---

## 🔹 Step 1 — Identify Nodes

List all nodes in your kind or cluster setup:
```bash
kubectl get nodes -o wide
```

Pick a node where you want to pin your `demo-deployment` Pods — usually:
```
kind-control-plane
```

---

## 🔹 Step 2 — Apply Node Label

Your Deployment includes this Node Affinity rule:
```yaml
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: kubernetes.io/os
            operator: In
            values:
              - linux
```

Make sure the target node is labeled correctly:
```bash
kubectl get nodes
kubectl label node < your-target-node-name > kubernetes.io/os=linux --overwrite
```

✅ **Purpose:** Ensures Pods are only scheduled on Linux-based nodes (which all kind nodes are, but it’s a good practice for consistency).

---

## 🔹 Step 3 — Apply a Taint

Now, taint the same node so only tolerant Pods (like your demo Deployment) can run there.

```bash
kubectl get nodes
kubectl taint nodes < your-target-node-name > demo=true:NoSchedule
```

This prevents **non-tolerant** Pods from being scheduled on this node.

---

## 🔹 Step 4 — Confirm Tolerations Exist

Your `demo-deployment.yaml` already includes:

```yaml
tolerations:
  - key: "demo"
    operator: "Exists"
    effect: "NoSchedule"
```

This allows those Pods to **bypass the taint** applied above.

If not sure, double-check:
```bash
kubectl get deployment demo-deployment -n demo -o yaml | grep -A5 tolerations
```

---

## 🔹 Step 5 — Redeploy or Restart Pods

To ensure new scheduling happens according to taint/affinity rules:
```bash
kubectl rollout restart deployment demo-deployment -n demo
```

Wait for Pods to reschedule:
```bash
kubectl get pods -n demo -o wide
```

You should now see Pods **only on the tainted node**.

---

## 🔍 Step 6 — Verification

### Check Node Taints:
```bash
kubectl describe node < your-target-node-name > | grep -A2 Taints
```

Expected:
```
Taints: demo=true:NoSchedule
```

### Check Pod Scheduling:
```bash
kubectl get pods -n demo -o wide
```
✅ Both replicas of `demo-deployment` should run on the **tainted and labeled node**.

---

## 🧹 Optional Cleanup
If you need to revert taints:
```bash
kubectl taint nodes < your-target-node-name > demo=true:NoSchedule-
```

---

## 🧭 Summary

| Feature | Applied On | Description | Purpose |
|----------|-------------|-------------|----------|
| **Taint** | Node | Prevents Pods from scheduling unless tolerated | Node-level workload isolation |
| **Toleration** | Pod | Allows scheduling on tainted node | Grants permission to run on restricted nodes |
| **Node Affinity** | Pod | Forces Pod scheduling on specific labeled nodes | Ensures Pods land only on matching nodes |

---

### ✅ End Result
After following this guide:
- `demo-deployment` Pods will **only** run on nodes with `kubernetes.io/os=linux`.  
- They’ll also **tolerate the demo taint**, proving affinity + toleration coexistence.  
- Other Pods **without** this toleration won’t schedule there.

---

> 💡 Tip: These techniques are essential in production to control workload placement for isolation, compliance, and performance optimization.
