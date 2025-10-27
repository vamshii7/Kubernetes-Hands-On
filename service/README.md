# 🧭 Kubernetes Services — Deep Dive with Examples and Diagram

## 📘 Overview
A **Service** provides a stable network endpoint for accessing a group of Pods.  
It hides Pod IP changes and enables service discovery inside and outside the cluster.

## Types of Services
- ClusterIP (default) — internal-only access
- NodePort — expose on a node port for external access
- LoadBalancer — integrates with cloud provider LB
- ExternalName — maps to external DNS name

---

## 🧱 Service Type Examples

### 🌀 ClusterIP Service
Used for **internal-only** communication within the cluster.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
  labels:
    app: nginx
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: ClusterIP
```

### 🌐 NodePort Service
Exposes app on a **static port (30000–32767)** on each node’s IP.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
  type: NodePort
```

### ☁️ LoadBalancer Service
Creates a **cloud provider-managed load balancer** (AKS, EKS, GKE).
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
```

### 🌍 ExternalName Service
Maps a Service name to an **external DNS name**.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-google
spec:
  type: ExternalName
  externalName: www.google.com
```

---

## 📊 Diagram — Service Routing Flow

```text
               +---------------------+
               |  External Client     |
               +---------+-----------+
                         |
         +---------------+----------------+
         |         Service Types          |
         +--------------------------------+
         |                                |
  +---------------+               +-----------------+
  | ClusterIP     |               | LoadBalancer    |
  | Internal Only |               | External Access |
  +-------+-------+               +--------+--------+
          |                                |
  +-------v-------+                +-------v--------+
  |    Pod(s)     |                |     Pod(s)     |
  +---------------+                +----------------+

  +--------------------------------------------+
  | NodePort                                   |
  | Accessible via <NodeIP>:<NodePort>         |
  +--------------------------------------------+

  +--------------------------------------------+
  | ExternalName                               |
  | Redirects traffic to external DNS (e.g.,   |
  | www.google.com)                            |
  +--------------------------------------------+
```

---

## How it fits in the cluster lifecycle
- Services select Pods via labels and proxy traffic to matching endpoints (endpoints object or EndpointSlices).
- Services are frequently used with Deployments, StatefulSets, and ReplicaSets to expose Pods reliably.

## Core CLI Reference
- Create Service: `kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP`
- Apply manifest: `kubectl apply -f service.yaml`
- Get: `kubectl get svc -A`
- Describe: `kubectl describe svc <name>`
- Delete: `kubectl delete svc <name>`

## Explained YAML (key fields)
- `spec.selector`: label selector for backing Pods
- `spec.ports[]`: port, targetPort, protocol
- `spec.type`: service type (ClusterIP/NodePort/LoadBalancer)

## Practical Use-Cases
- Internal microservice communication (ClusterIP)
- Exposing HTTP via Ingress with ClusterIP services
- NodePort for bare-metal clusters
- LoadBalancer for cloud-hosted clusters

## Best Practices
- Prefer ClusterIP + Ingress for HTTP services
- Use readinessProbe to ensure service endpoints are healthy
- Avoid using NodePort for production unless necessary

## Troubleshooting Checklist
- Check endpoints: `kubectl get endpoints <svc-name>` or `kubectl get endpointslices -n <ns>`
- Ensure service selector labels match Pod labels
- For LoadBalancer, verify cloud provider integration and events
