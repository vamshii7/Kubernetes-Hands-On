# StatefulSets — Kubernetes Deep Dive

## Overview
**StatefulSet** manages stateful applications that require stable, unique network identities and persistent storage (e.g., databases). It provides stable Pod names, ordered deployment/termination, and stable storage via PVCs.

## How it fits in the cluster lifecycle
- Pods in StatefulSet are created in order (`0..N-1`) and have stable persistent volume claims bound to them.
- Useful for databases and clustered systems needing stable identity.

## Core CLI Reference
- Apply: `kubectl apply -f statefulset.yaml`
- Get: `kubectl get statefulsets -A`
- Describe: `kubectl describe statefulset <name>`
- Scale: `kubectl scale statefulset <name> --replicas=3`
- Delete: `kubectl delete statefulset <name>`

## Explained YAML
- `spec.volumeClaimTemplates` for per-pod PVCs
- `spec.podManagementPolicy` (OrderedReady/Parallel)
- `spec.updateStrategy` (RollingUpdate/OnDelete)

## Practical Use-Cases
- Databases (MySQL, Postgres), Kafka brokers, Zookeeper
- Any workload that requires persistent identity and storage

## Best Practices
- Use volumeClaimTemplates to guarantee per-pod persistent storage.
- Prefer ReadWriteOnce PV types for single-writer use cases.
- Test failover and recovery procedures thoroughly.

## Troubleshooting Checklist
- Check PVC/PV binding using `kubectl get pvc -n <ns>`
- Ensure storage class supports the access mode required