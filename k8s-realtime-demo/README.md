# 🚀 Kubernetes Realtime Demo (NodePort + Namespace Based)

This is a **complete end-to-end Kubernetes demo** that brings together multiple concepts:
ConfigMaps, Secrets, Probes, Affinity, Taints, HPA, and NodePort Service — all running inside a custom namespace.

---

## 🧩 Prerequisites
- A running Kubernetes cluster (kind / minikube / AKS / GKE / EKS)
- `kubectl` CLI configured to access the cluster
- Metrics Server installed (for HPA to work)
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```
- `kubectl get nodes` should show at least one Ready node

---

## ⚙️ Setup Steps

### 1️⃣ Create Namespace
```bash
kubectl apply -f namespace-demo.yaml
```

### 2️⃣ Deploy ConfigMap and Secret
```bash
kubectl apply -f configmap.yaml -n demo
kubectl apply -f secret.yaml -n demo
```

### 3️⃣ Deploy Application
```bash
kubectl apply -f deployment.yaml -n demo
```

### 4️⃣ Expose using NodePort
```bash
kubectl apply -f service-nodeport.yaml -n demo
```

### 5️⃣ Enable HPA (optional)
```bash
kubectl apply -f hpa.yaml -n demo
```

### 6️⃣ Access App
```bash
kubectl get svc -n demo
```
Then visit:
```
http://<NodeIP>:30080
```

For kind:
```bash
kubectl get nodes -o wide
```
Use the internal IP of your kind node.

---

## 🧠 Learning Outcomes
✔ Namespace isolation  
✔ Using ConfigMap + Secret together  
✔ Probes (liveness, readiness)  
✔ Affinity + toleration combo  
✔ NodePort exposure  
✔ HPA scaling demonstration  

---

## 🧹 Cleanup
```bash
kubectl delete ns demo
```

---
