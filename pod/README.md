# Pods — Kubernetes Deep Dive

## Overview
A **Pod** is the smallest deployable unit in Kubernetes. It encapsulates one or more containers that share network namespace (localhost) and storage volumes. Pods are ephemeral by design — they can be created, destroyed, and replaced by higher-level controllers like Deployments.

## How it fits in the cluster lifecycle
- Pods are scheduled onto Nodes by the scheduler.
- Containers inside Pods share the Pod IP and can communicate via `localhost` ports.
- For durability or scaling, Pods are typically managed by controllers (Deployment, ReplicaSet, StatefulSet).

## Core CLI Reference
- Create from manifest: `kubectl apply -f pod.yaml`
- Run ephemeral Pod: `kubectl run mypod --image=nginx --restart=Never`
- Get Pods: `kubectl get pods -A` or `kubectl get pods -o wide`
- Describe Pod: `kubectl describe pod <pod-name> -n <namespace>`
- View logs: `kubectl logs <pod-name> [-c <container>]`
- Exec into a container: `kubectl exec -it <pod-name> -c <container> -- /bin/sh`
- Delete Pod: `kubectl delete pod <pod-name>`

## Explained YAML (sample explained)
A simple Pod manifest contains:
- `apiVersion`, `kind: Pod`, `metadata` (name, labels)
- `spec.containers[]` array with container image, ports, env, volumeMounts
- `spec.volumes[]` for shared volumes (emptyDir, configMap, secret, pvc)
- `restartPolicy` e.g., `Always`, `OnFailure`, `Never`

**Note:** For production workloads prefer Deployments/StatefulSets — Pods alone do not provide self-healing or scaling.

## Practical Use-Cases
- Debugging and one-off tasks (`kubectl run --rm -it ...`)
- Sidecar patterns when colocating closely-coupled containers
- Local testing in a development namespace

## Best Practices
- Don’t run multiple unrelated processes in a single Pod. Use containers for tightly coupled processes only.
- Attach resource requests/limits to containers.
- Use readiness and liveness probes to manage pod lifecycle.
- Distinguish between ephemeral (Jobs) and long-running workloads (Deployments).

## Troubleshooting Checklist
- `kubectl describe pod` to inspect events (scheduling, pull errors, mount errors)
- `kubectl logs` per container for runtime errors
- Ensure ImagePullSecrets are configured if using private registries
- Inspect node readiness (`kubectl get nodes`) if pods stuck Pending
