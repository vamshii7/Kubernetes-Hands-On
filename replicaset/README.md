# ReplicaSets — Kubernetes Deep Dive

## Overview
A **ReplicaSet** ensures a specified number of Pod replicas are running. Deployments manage ReplicaSets; direct use of ReplicaSets is less common but useful for understanding scaling primitives.

## How it fits in the cluster lifecycle
- ReplicaSet watches Pods via label selector and creates/deletes Pods to match `replicas` count.
- ReplicaSets are created automatically by Deployments during rollout.

## Core CLI Reference
- Create: `kubectl apply -f replicaset.yaml`
- Get: `kubectl get replicasets -A`
- Describe: `kubectl describe rs <name>`
- Scale: `kubectl scale rs <name> --replicas=5`
- Delete: `kubectl delete rs <name>`

## Explained YAML
- `spec.replicas`
- `spec.selector.matchLabels`
- `spec.template` for pod template

## Practical Use-Cases
- Low-level control scenarios and learning/testing of how controllers manage pods
- Legacy setups where you want direct control over ReplicaSets (rare)

## Best Practices
- Prefer Deployments for declarative update patterns.
- Keep selectors and template labels consistent to avoid orphaned pods.

## Troubleshooting Checklist
- Mismatched selectors lead to no pod creation — verify labels
- Resource exhaustion on nodes causing pods to be Pending
