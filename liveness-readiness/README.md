# Probes — Liveness, Readiness, Startup — Kubernetes Deep Dive

## Overview
Probes are health checks Kubernetes uses to manage container lifecycle:
- **Liveness probe**: determines if a container should be restarted
- **Readiness probe**: determines if a container is ready to accept traffic
- **Startup probe**: used for slow-starting containers to delay liveness checks

# 🩺 Kubernetes Probes Examples

---

## 1. Liveness Probe Example
**File:** `liveness-probe.yaml`

🧠 **Use case:**  
If the NGINX process hangs or the endpoint fails to return HTTP 200, Kubernetes restarts the container — ensuring self-healing.

---

## 2. Readiness Probe Example
**File:** `readiness-probe.yaml`

🧠 **Use case:**  
Ensures that only healthy Pods receive traffic. If the NGINX process hangs or the endpoint fails to return HTTP 200, Kubernetes marks the Pod as **unready** and removes it from Service endpoints.

---

## 3. Startup Probe Example
**File:** `startup-probe.yaml`

🧠 **Explanation:**  
`startupProbe` ensures the container isn’t restarted while the app is still booting up.  
Once it passes, Kubernetes enables the `livenessProbe` — balancing resilience with patience for slow apps (e.g., Spring Boot, Java, or large microservices).

---

## 💡 Production Best Practices

| Probe Type | When It’s Checked           | Primary Goal                              | Typical Config          |
|------------|-----------------------------|-------------------------------------------|-------------------------|
| **Liveness** | Throughout Pod lifetime     | Detect and recover from stuck containers   | HTTP GET or TCP         |
| **Readiness** | During startup & runtime    | Ensure only healthy Pods get traffic       | HTTP GET, TCP, or Exec  |
| **Startup**   | During container init       | Give time for slow apps to boot            | HTTP GET or Exec        |

---


## How it fits in the cluster lifecycle
- Kubelet calls probe endpoints and acts on results (restart container or update Endpoints).
- Readiness affects Service endpoints; liveness affects container restarts.

## Core CLI Reference
- Probes are specified in Pod/Deployment YAML under `containers[].livenessProbe`, `readinessProbe`, `startupProbe`
- Validate config: `kubectl apply -f probe.yaml`
- Debug using `kubectl describe pod <name>` and container logs

## Probe Types
- `httpGet` (path, port)
- `tcpSocket` (port)
- `exec` (command returns 0 for success)

## Best Practices
- Use readiness to prevent traffic to containers that are still initializing.
- Tune initialDelaySeconds, periodSeconds, timeoutSeconds to balance sensitivity.
- Use startupProbe for apps with long initialization (e.g., JVM, migrations).

## Troubleshooting Checklist
- Check probe failure reasons in `kubectl describe pod` events
- Ensure the probe path is reachable inside the container (use `kubectl exec` to test)
