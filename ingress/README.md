# Ingress — Kubernetes Deep Dive

## Overview
**Ingress** defines HTTP/S routing rules to Services. It enables virtual hosts, path-based routing, TLS termination, and host-based routing.

## How it fits in the cluster lifecycle
- Ingress resources are interpreted by an Ingress Controller (e.g., NGINX, Traefik, Contour).
- The controller watches Ingress objects and programs underlying proxy/load-balancer configurations.

## Core CLI Reference
- Apply ingress: `kubectl apply -f ingress.yaml`
- Get: `kubectl get ingress -A`
- Describe: `kubectl describe ingress <name>`
- Check controller logs (namespace depends on controller): `kubectl logs -n ingress-nginx deploy/ingress-nginx-controller`

## Explained YAML (important fields)
- `spec.rules[]` with `host` and `http.paths[]`
- `spec.tls[]` for TLS secret references
- `backend` default and per-path backend service

## Practical Use-Cases
- Host-based routing for multiple domains
- TLS offloading and certificate management
- Path-based routing to microservices

## Best Practices
- Use cert-manager for automated cert issuance and rotation
- Define a default backend to handle unmatched requests
- Use annotations sparingly and document them (controller-specific)

## Troubleshooting Checklist
- If 404s occur: check Ingress rules and Service targets
- If TLS errors: validate Secret with certificate and key, and ensure controller supports TLS configuration
