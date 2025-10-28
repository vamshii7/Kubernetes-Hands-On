# 🔐 ConfigMaps & Secrets — Kubernetes Deep Dive

## 🌐 Overview
In Kubernetes, configuration and secrets are first-class citizens.
Instead of embedding configuration inside container images,
Kubernetes allows you to **externalize configuration** and **secure sensitive data** through:

- 🗂️ **ConfigMaps** — for non-sensitive configuration data
- 🔑 **Secrets** — for sensitive data like passwords or tokens

This separation improves flexibility, reusability, and security.
This approach decouples configuration from application code, enabling updates without rebuilding or redeploying containers.
---

## 🔄 How They Fit in the Cluster Lifecycle
- Pods consume ConfigMaps/Secrets via **environment variables** or **mounted volumes**.
- ConfigMap changes can propagate automatically (depending on mount type).
- Secrets reside in etcd — ensure encryption at rest.

---

## 🧰 Core CLI Reference
```bash
kubectl create configmap app-config --from-literal=KEY=value
kubectl create secret generic db-secret --from-literal=password=supersecret
kubectl get configmaps,secrets
kubectl describe secret db-secret
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 --decode
```

---

## 🧾 YAML Examples
1️⃣ **ConfigMap as Environment Variable**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_MODE: production
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-config-env
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo $APP_MODE && sleep 3600"]
    envFrom:
    - configMapRef:
        name: app-config
```

2️⃣ **ConfigMap as Mounted Volume**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-vol
data:
  app.conf: |
    feature=enabled
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-config-vol
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "cat /etc/config/app.conf && sleep 3600"]
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config-vol
```

3️⃣ **Secret as Environment Variable**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  username: admin
  password: myS3cretPass
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret-env
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo $DB_USER && sleep 3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

4️⃣ **Secret Mounted as File**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-key
type: Opaque
data:
  id_rsa: c3NoLXByaXZhdGUtY2tlCg==
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret-vol
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "ls /etc/ssh && sleep 3600"]
    volumeMounts:
    - name: ssh
      mountPath: /etc/ssh
      readOnly: true
  volumes:
  - name: ssh
    secret:
      secretName: ssh-key
```

5️⃣ **Secrets with stringData (Simplified Creation)**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  username: admin
  password: myS3cretPass
```
---

## 💡 Practical Use Cases

### 🏷️ ConfigMaps

- Store environment variables for microservices
- Define feature flags or toggles
- Manage app configuration files

### 🔐 Secrets

- Store database credentials
- Handle TLS certificates
- Manage API tokens and SSH keys

---

## 💡 Best Practices
- 🔒 Enable encryption at rest for Secrets.
- 🚫 Never commit Secrets to Git (even base64-encoded).
- 🧭 Use external secret managers (Vault, Key Vault, etc.) for production.
- 🧹 Keep ConfigMaps & Secrets namespace-scoped.
- 🧠 Remember: base64 encoding ≠ encryption!
- ✅ Use stringData in YAML for readability — it’s automatically encoded

---

## 🛠️ Troubleshooting Checklist

| Issue                         | Check / Fix                                                                 |
|-------------------------------|------------------------------------------------------------------------------|
| ❌ Pod cannot access keys      | Verify mount paths & file permissions                                        |
| 📍 Secret not found            | Ensure Secret exists in same namespace                                       |
| 🔎 Missing environment vars    | Run `kubectl describe pod <pod>`                                             |
| 🧪 Decode validation           | `kubectl get secret <name> -o jsonpath='{.data.<key>}' | base64 --decode`    |
| 🛡️ External store sync issues  | Ensure secret sync controller is running                                     |


- ❌ Secret missing → Ensure same namespace.
- 🔍 Verify mounts with `kubectl describe pod`.
- 🧩 Check CNI or volume permissions if unreadable.
