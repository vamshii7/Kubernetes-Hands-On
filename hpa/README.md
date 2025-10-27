# Horizontal Pod Autoscaler (HPA) — Kubernetes Deep Dive

## Overview
HPA automatically scales the number of pod replicas for a Deployment, ReplicaSet, or StatefulSet based on observed metrics (CPU, memory, or custom metrics).

## How it fits in the cluster lifecycle
- HPA queries the metrics API (metrics-server or Prometheus adapter) and adjusts `spec.replicas` of the target resource.
- Combined with Cluster Autoscaler, HPA enables dynamic capacity management.

## Core CLI Reference
- Create HPA: `kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=70`
- Apply manifest: `kubectl apply -f hpa.yaml`
- Get: `kubectl get hpa -A`
- Describe: `kubectl describe hpa <name>`

## Explained YAML (fields)
- `scaleTargetRef` target resource
- `minReplicas`, `maxReplicas`, `metrics`

## Best Practices
- Ensure resource requests are set for containers (HPA uses them to calculate utilization)
- Use custom metrics for advanced scaling (queue length, latency)
- Test scaling behavior under load in staging

## Troubleshooting Checklist
- If HPA shows no metrics: ensure metrics-server is deployed and functioning
