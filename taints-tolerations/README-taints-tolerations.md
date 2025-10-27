# Taints & Tolerations — Kubernetes Deep Dive

## Overview
**Taints** allow nodes to repel Pods that don’t explicitly tolerate them.  
**Tolerations** are applied on Pods to allow scheduling onto tainted nodes.

They work together to ensure Pods are only placed on appropriate nodes, offering finer scheduling control.

## How It Fits in the Cluster Lifecycle
- Taints are set on nodes by cluster admins.
- Tolerations are applied in Pod specs.
- The scheduler avoids tainted nodes unless Pods tolerate those taints.

## Core CLI Reference
- Add a taint: `kubectl taint nodes <node-name> key=value:NoSchedule`
- Remove taint: `kubectl taint nodes <node-name> key=value:NoSchedule-`
- Get node taints: `kubectl describe node <node-name>`
- Apply Pod with toleration: `kubectl apply -f taints-tolerations.yaml`

## Example YAML (taints-tolerations-example.yaml)
See: [taints-tolerations-example.yaml](./taints-tolerations-example.yaml)

## Taint Effects
- **NoSchedule:** Pods won’t schedule unless tolerated.
- **PreferNoSchedule:** Scheduler avoids but doesn’t strictly prevent scheduling.
- **NoExecute:** Existing Pods are evicted if they don’t tolerate the taint.

## Practical Use-Cases
- Dedicating nodes for system workloads or databases.
- Isolating GPU or sensitive workloads.
- Preventing scheduling on nodes under maintenance.

## Best Practices
- Always document taint purpose in node annotations.
- Use **NoExecute** carefully—it can evict critical Pods.
- Pair with node affinity for optimal placement control.

## Troubleshooting
- Pods stuck Pending → Check taints on nodes.
- Use `kubectl describe pod` for events about taints.
- Ensure tolerations match taint key/value/effect exactly.
