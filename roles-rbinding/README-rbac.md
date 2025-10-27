# RBAC — Roles, RoleBindings, ClusterRoles, ServiceAccounts — Kubernetes Deep Dive

## Overview
RBAC (Role-Based Access Control) controls who can do what in the cluster. Roles are namespace-scoped, ClusterRoles are cluster-scoped. RoleBindings/ClusterRoleBindings bind Roles to users, groups or ServiceAccounts.

## How it fits in the cluster lifecycle
- ServiceAccounts are used by Pods to authenticate with the API server.
- Roles and ClusterRoles define permissions for API resources.
- Bindings attach those permissions to identities (users, groups, or service accounts).

## Core CLI Reference
- Create Role: `kubectl create role pod-reader --verb=get,list,watch --resource=pods -n dev`
- Create RoleBinding: `kubectl create rolebinding read-pods --role=pod-reader --user=alice -n dev`
- Create ClusterRole: `kubectl create clusterrole cluster-admin-view --verb=get,list --resource=pods`
- Create ClusterRoleBinding: `kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=admin`
- Inspect: `kubectl get roles,rolebindings,clusterroles,clusterrolebindings -A`
- Describe binding: `kubectl describe rolebinding <name> -n <ns>`

## Practical Use-Cases
- Restrict tenant namespaces to only deploy certain resources.
- Grant CI/CD pipeline service account permissions for deployments.

## Best Practices
- Follow least privilege principle.
- Use dedicated service accounts for automation and rotate credentials where applicable.
- Test policies with `kubectl auth can-i --as system:serviceaccount:<ns>:<sa> create deployments`

## Troubleshooting Checklist
- If auth fails for a pod: check ServiceAccount, Secret token, and RoleBinding existence.