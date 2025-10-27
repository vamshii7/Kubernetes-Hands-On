# 🌟 Kubernetes Hands-On Labs Repository

![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.30-blue?logo=kubernetes)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-kind%20%7C%20minikube%20%7C%20AKS-blueviolet)

A comprehensive, ready-to-use **Kubernetes learning repository** packed with practical YAML manifests, Dockerfiles, scripts, and automation examples.  
This project helps you **learn, test, and master** Kubernetes features locally (with kind or Minikube)

---

## 📁 Repository Structure

| Directory | Description |
|------------|-------------|
| `auth/` | Kubernetes authentication and RBAC examples (ServiceAccount, Roles, RoleBindings). |
| `configmaps-secrets/` | Examples for environment variables and sensitive data management. |
| `daemonset/` | Run pods on every node using DaemonSets (e.g., monitoring agents). |
| `deployments/` | Core Deployment YAMLs showing scaling, rolling updates, and strategy. |
| `docker/` | Dockerfiles and static assets for sample app images. |
| `hpa/` | Horizontal Pod Autoscaler manifests for resource-based scaling. |
| `ingress/` | Ingress examples with path-based routing and host rules. |
| `jobs/` | Job and CronJob YAMLs for batch and scheduled workloads. |
| `kind-cluster/` | Kind cluster configuration and automation script. |
| `liveness-readiness/` | Probes demonstrating health checks and failure recovery. |
| `multi-container-pod/` | Multi-Container Pod Patterns in Kubernetes. |
| `network-policy/` | NetworkPolicy configurations for pod communication control. |
| `nodeaffinity/` | Node affinity and anti-affinity scheduling examples. |
| `pod/` | Basic pod definitions for fundamental Kubernetes learning. |
| `quota/` | Namespace-level ResourceQuota configurations. |
| `replicaset/` | ReplicaSet manifests for stateless app replication. |
| `roles-rbinding/` | Role, RoleBinding, and ServiceAccount RBAC configurations. |
| `scripts/` | Bash automation scripts for cluster creation and management. |
| `service/` | Service examples (ClusterIP, NodePort, LoadBalancer). |
| `taints-tolerations/` | Demonstrations of scheduling using taints and tolerations. |
| `task/` | Guided practice tasks for Kubernetes exam and interview preparation. |
| `volumes/` | PersistentVolume and PersistentVolumeClaim examples. |

---

## 🚀 Quick Start

### 🧩 Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) CLI
- (Optional) Helm for chart-based deployments

### 📦 Clone the Repository

```bash
git clone https://github.com/vamshii7/Kubernetes.git
cd Kubernetes
```

### 🧱 Create a Kind Cluster

```bash
cd kind-cluster
kind create cluster --config kind-config.yaml
```

Verify cluster nodes:
```bash
kubectl get nodes
```

### 🐳 Deploy a Sample Application

```bash
kubectl apply -f deployments/nginx-deployment.yaml
kubectl apply -f service/clusterip-service.yaml
```

Verify the running pods and services:
```bash
kubectl get pods
kubectl get svc
```

### 🌐 Access Using Ingress (optional)

If you have an Ingress controller (like NGINX ingress) installed:

```bash
kubectl apply -f ingress/ingress-example.yaml
```
Then add the host mapping in `/etc/hosts`:
```
127.0.0.1 example.local
```
Access your app at [http://example.local](http://example.local)

---

## 🧠 Learning Path

1. Start with `pod/` and `service/` basics  
2. Move to `deployments/` for scalable apps  
3. Configure health checks via `liveness-readiness/`  
4. Enable autoscaling using `hpa/`  
5. Secure workloads using `auth/`, `roles-rbinding/`, and `network-policy/`  
6. Manage persistent data using `volumes/`  
7. Optimize scheduling with `nodeaffinity/` and `taints-tolerations/`  

---

## 🧰 Tools & Versions

| Tool | Version |
|------|----------|
| Kubernetes | v1.30+ |
| Docker | 24.x |
| kind | 0.22+ |
| kubectl | v1.30+ |

---

## 🧪 Advanced Scenarios

- CI/CD pipelines integration with GitHub Actions or Azure DevOps  
- AKS RBAC integration with Azure Entra ID  
- Prometheus & Grafana monitoring setup  
- NetworkPolicy enforcement with Calico  
- Volume provisioning with CSI drivers (Azure Files, AWS EBS, Rook-Ceph)

---

## ✍️ Authors

👨‍💻 **Vamshi Krishna**  
DevOps Engineer | DevOps & Kubernetes Enthusiast  

📫 Reach out on  [GitHub](https://github.com/vamshii7)   •  [LinkedIn](https://www.linkedin.com/in/vamshi7/)  
🌐 Focus Areas: Terraform, AKS, Azure DevOps, Kubernetes, and Cloud Automation  
🚀 Building hands-on labs for real-world learning!  

> ⚙️ _Feel free to fork and contribute — PRs are welcome!_
