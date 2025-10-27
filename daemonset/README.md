# DaemonSets — Kubernetes Deep Dive

## Overview
A **DaemonSet** ensures that a copy of a Pod runs on each node (or a subset via nodeSelector/taints). Commonly used for node-level agents like log collectors, monitoring agents, or networking plugins.

## How it fits in the cluster lifecycle
- DaemonSet controller watches nodes and creates/deletes pods to maintain one-per-node semantics.
- New nodes get the DaemonSet Pod automatically.

## Core CLI Reference
- Apply: `kubectl apply -f daemonset.yaml`
- Get: `kubectl get daemonsets -A`
- Describe: `kubectl describe daemonset <name>`
- Delete: `kubectl delete daemonset <name>`

## Explained YAML
- `spec.selector` and `spec.template` define the daemon pod template
- `spec.updateStrategy` (RollingUpdate or OnDelete)
- nodeSelectors, tolerations, and affinity to control placement

## Practical Use-Cases
- Log/metrics collectors (Fluentd, Prometheus node-exporter)
- CNI plugins (Calico, Cilium)
- System daemons like filebeat or security agents

## Best Practices
- Use tolerations to ensure system nodes get necessary pods.
- Constrain resource usage to avoid starving workloads.
- Use `hostPath` carefully for node-level access (security risk).

## Troubleshooting Checklist
- Check node readiness and taints if pods are not created on nodes.
- Inspect daemonset status: `kubectl get ds <name> -o yaml` to view `numberReady`, `desiredNumberScheduled`
