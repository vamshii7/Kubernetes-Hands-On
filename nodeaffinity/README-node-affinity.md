# Node Affinity — Kubernetes Deep Dive

## Overview
**Node Affinity** allows you to control Pod placement based on node labels. It provides flexible rules that influence the scheduler’s decisions to co-locate or separate workloads efficiently.

## How It Fits in the Cluster Lifecycle
- Node affinity is evaluated **when the Pod is scheduled**.
- It uses **node labels** as selection criteria.
- Changes in node labels don’t evict already running Pods automatically.

## Types of Node Affinity
1. **requiredDuringSchedulingIgnoredDuringExecution**  
   - Hard requirement: Pods will only schedule if nodes match.
2. **preferredDuringSchedulingIgnoredDuringExecution**  
   - Soft requirement: Scheduler tries to match but may place elsewhere if unavailable.

## Core CLI Reference
- Label a node: `kubectl label node <node-name> disktype=ssd`
- View labels: `kubectl get nodes --show-labels`
- Apply manifest: `kubectl apply -f node-affinity.yaml`
- Describe Pod: `kubectl describe pod <pod-name>`
- Remove label: `kubectl label node <node-name> disktype-`

## Example YAML (node-affinity-example.yaml)
See: [node-affinity-example.yaml](./node-affinity-example.yaml)

## Practical Use-Cases
- Running database workloads on SSD nodes.
- Keeping GPU workloads on GPU-labeled nodes.
- Zone or region-based workload separation in multi-AZ clusters.

## Best Practices
- Use **node selectors** for simple one-label rules; use **affinity** for complex matching.
- Combine with **taints/tolerations** for more robust scheduling control.
- Maintain consistent labeling standards across clusters.

## Troubleshooting
- If Pod remains Pending, check node labels and scheduler events.
- Verify label names match exactly (case-sensitive).
- Use `kubectl describe pod` to inspect failed scheduling reasons.
