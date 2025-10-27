# Deployments — Kubernetes Deep Dive

## Overview
A **Deployment** declaratively manages ReplicaSets and Pods to provide rolling updates, rollbacks, scaling, and self-healing for stateless applications.

## How it fits in the cluster lifecycle
- You declare desired state in a Deployment spec (replica count, template, updateStrategy).
- Kubernetes creates a ReplicaSet to maintain the requested number of Pods.
- Deployments support rolling updates using `strategy.type: RollingUpdate` by default.

## Core CLI Reference
- Create/Apply: `kubectl apply -f deployment.yaml`
- Create quick deployment: `kubectl create deployment nginx --image=nginx`
- Get deployments: `kubectl get deployments -A`
- Describe: `kubectl describe deployment <name>`
- Scale: `kubectl scale deployment <name> --replicas=3`
- Rollout status: `kubectl rollout status deployment/<name>`
- Rollback: `kubectl rollout undo deployment/<name>`
- Edit live: `kubectl edit deployment <name>`
- Delete: `kubectl delete deployment <name>`

## Explained YAML (what to include)
- `spec.replicas`: desired number of pod replicas
- `spec.selector.matchLabels`: label selector for ReplicaSet
- `spec.template`: Pod template (labels must match selector)
- `spec.strategy`: RollingUpdate settings (`maxUnavailable`, `maxSurge`)
- `spec.template.spec.containers[]`: containers, probes, resources

## Practical Use-Cases
- Stateless microservices
- Canary and blue-green deployments with traffic shaping tools
- Autoscaling with HPA

## Best Practices
- Use liveness/readiness probes to avoid sending traffic to non-ready pods.
- Keep `revisionHistoryLimit` reasonable to save cluster storage.
- Pin image tags for production (avoid `:latest`).
- Use resource requests/limits for predictable scaling and accurate HPA behavior.
- Use `spec.strategy.rollingUpdate` tuning to manage availability during updates.

## Troubleshooting Checklist
- If rollout stuck: `kubectl rollout status`, `kubectl describe deployment` to see events
- Check ReplicaSet and Pod statuses: `kubectl get rs`, `kubectl get pods -l <app-label>`
- Container image pull errors: `kubectl describe pod` -> ImagePullBackOff
- Probe misconfiguration: check container logs and probe endpoints
