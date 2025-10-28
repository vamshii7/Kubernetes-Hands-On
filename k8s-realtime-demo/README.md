# 🚀 Kubernetes Realtime Demo

This is a **complete end-to-end Kubernetes demo** that brings together multiple concepts:

## 🧩 Includes:
✅ ConfigMaps and Secrets  
✅ Volumes (PV & PVC)  
✅ Multi-Container Pods  
✅ Liveness & Readiness Probes  
✅ Node Affinity  
✅ Taints & Tolerations  
✅ HPA (Horizontal Pod Autoscaler)  
✅ Ingress with NGINX  
✅ NodePort Service for verification 

---

## ⚙️ Prerequisites

Ensure you have:
- 🧰 **kind** or **minikube** cluster running
- 📦 Metrics Server installed for HPA:
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```
- 🗂️ Create storage path on node:
  ```bash
  docker exec -it kind-control-plane mkdir -p /mnt/data/demo-storage
  ```
- 🧱 Enable NGINX ingress controller (for kind):
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  ```

---

## 🚀 Deployment Steps

### 1️⃣ Create Namespace and Volume
```bash
kubectl apply -f namespace.yaml
kubectl apply -f pv-pvc.yaml
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
kubectl apply -f service.yaml -n demo
```

### 5️⃣ (optional) Enable HPA  and Ingress
```bash
kubectl apply -f hpa.yaml -n demo
kubectl apply -f ingress.yaml
```

## 🔍 Verification

Check resources:
```bash
kubectl get all -n demo
kubectl get pvc -n demo
kubectl get pv
kubectl describe pod -n demo
```

### 6️⃣ Access App
Access app via NodePort:
```bash
kubectl get svc -n demo
curl http://localhost:30080
```
If using ingress (add entry to /etc/hosts):
```
127.0.0.1 demo.local
```
Then access:
```
http://demo.local
```

---

## 🧠 Learning Outcomes
✔ Namespace isolation  
✔ Using ConfigMap + Secret together  
✔ Probes (liveness, readiness)  
✔ Affinity + toleration combo  
✔ NodePort exposure  
✔ HPA scaling demonstration  
✔ Volumes (PV & PVC)  
✔ Ingress with NGINX

---

## 🧹 Cleanup
```bash
kubectl delete ns demo
```

---