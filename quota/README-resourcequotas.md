# ResourceQuotas & LimitRanges — Kubernetes Deep Dive

## Overview
**ResourceQuota** limits total consumable resources (CPU, memory, object counts) in a namespace. **LimitRange** enforces defaults/limits for containers within a namespace.

## How it fits in the cluster lifecycle
- ResourceQuota prevents teams from consuming more than allocated resources in a namespace.
- LimitRange ensures pods/containers get default requests/limits if not specified, preventing scheduling surprises.

## Core CLI Reference
- Apply: `kubectl apply -f resourcequota.yaml`
- Get: `kubectl get resourcequota -n <namespace>`
- Describe: `kubectl describe resourcequota <name> -n <namespace>`
- Delete: `kubectl delete resourcequota <name> -n <namespace>`

## Best Practices
- Use ResourceQuota in multi-tenant clusters to enforce fair usage.
- Use LimitRange to ensure reasonable defaults and avoid OOMKills due to no requests.

## Troubleshooting Checklist
- If pod creation fails due to quota: `kubectl describe quota` shows used vs hard limits