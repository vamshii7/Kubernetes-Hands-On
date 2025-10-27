# ConfigMaps & Secrets — Kubernetes Deep Dive

## Overview
**ConfigMaps** store non-sensitive configuration (plain text) while **Secrets** store sensitive data (base64-encoded). Both are used to decouple configuration from container images and enable configuration updates without rebuilding images.

## How it fits in the cluster lifecycle
- Pods can consume ConfigMaps/Secrets as environment variables or mounted files.
- Changes to ConfigMaps mounted as volumes can be reflected in running Pods, depending on the container's ability to reload files.

## Core CLI Reference
- Create ConfigMap from literal/file: `kubectl create configmap app-config --from-literal=KEY=val` or `--from-file=path`
- Create Secret: `kubectl create secret generic db-secret --from-literal=password=...` or `--from-file=ssh.key`
- Get: `kubectl get configmaps`, `kubectl get secrets`
- Describe: `kubectl describe configmap <name>`
- View decoded secret: `kubectl get secret <name> -o jsonpath='{.data.KEY}' | base64 --decode`
- Use in workload: `envFrom`, `env`, or mount as volumes
- Delete: `kubectl delete configmap <name>`, `kubectl delete secret <name>`

## Explained YAML (usage patterns)
- `envFrom: - configMapRef: name: app-config`
- Volume mounts: `volumes[].configMap` or `volumes[].secret`
- Use `stringData` when creating Secrets from YAML for readability (it gets encoded automatically)

## Practical Use-Cases
- Feature flags, connection strings (ConfigMaps)
- Database credentials, TLS keys (Secrets)

## Best Practices
- Avoid storing extremely sensitive data in Secrets without encryption at rest (enable encryption of Secrets in the cluster)
- Use external secret stores for production-grade secret management
- Restrict RBAC access to Secrets
- Mount secrets as files with least privilege where possible

## Troubleshooting Checklist
- If pods cannot access keys, check volume mount paths and file permissions
- Confirm the Secret exists in the same namespace as the Pod
