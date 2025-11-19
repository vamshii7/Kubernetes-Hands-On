# Deployments - Kubernetes Deep Dive

## Overview
A **Deployment** declaratively manages ReplicaSets and Pods to provide rolling updates, rollbacks, scaling, and self-healing for stateless applications.

## How it fits in the cluster lifecycle
- You declare desired state in a Deployment spec (replica count, template, updateStrategy).
- Kubernetes creates a ReplicaSet to maintain the requested number of Pods.
- Deployments support rolling updates using `strategy.type: RollingUpdate` by default.

## Kubernetes Deployment - Core CLI Reference

| Command | Purpose |
|--------|---------|
| `kubectl apply -f deployment.yaml` | Apply a manifest (create/update) |
| `kubectl create deployment nginx --image=nginx` | Create a deployment quickly |
| `kubectl get deployments -A` | List all deployments across namespaces |
| `kubectl describe deployment <name>` | Show detailed deployment info |
| `kubectl scale deployment <name> --replicas=3` | Scale replicas |
| `kubectl rollout status deployment/<name>` | Check rollout progress |
| `kubectl rollout undo deployment/<name>` | Roll back to previous revision |
| `kubectl edit deployment <name>` | Edit deployment directly |
| `kubectl delete deployment <name>` | Delete a deployment |
| `kubectl set image TYPE/NAME CONTAINER=IMAGE` | Update container image |
| Example: `deployment/my-nginx` | ResourceType/ResourceName format |
| Example: `kubectl set image deployment/my-dep my-app=my-image:v2` | Update single container image  |
| Example: `kubectl set image deployment/my-dep c1=img1:v2 c2=img2:v3` | Update multiple containers image |


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

## This is an example of Fully Loaded Pod Spec  

### This YAML includes every feature a Deployment can possibly take:  

| ✔ Deployment | ✔ Pod template |
|----------------------------------|------------------------------|
| ✔ Sidecar                        | ✔ hostAliases               |
| ✔ TLS Secret                     | ✔ ConfigMap & Secret env    |
| ✔ imagePullSecrets               | ✔ probes                    |
| ✔ volumes (all major types shown)| ✔ resources                 |
| ✔ tolerations                    | ✔ pull policy               |
| ✔ podAffinity / podAntiAffinity  | ✔ annotations               |
| ✔ nodeAffinity & antiAffinity    | ✔ labels                    |
| ✔ serviceAccount                 | ✔ securityContext           |


```yaml
apiVersion: apps/v1                     # API version for Deployment objects
kind: Deployment                        # Declares this object is a Deployment
metadata:                               # Metadata section contains name, labels, annotations
  name: demo-deployment                 # Name of the Deployment
  labels:                               # Labels help identify and group resources
    app: demo-app                       # Label key-value pair
  annotations:                          # Optional metadata key-value pairs
    description: "Full commented demo"  # Example annotation

spec:                                   # Specification for the Deployment behavior
  replicas: 3                           # Number of pod replicas to run
  strategy:                             # Update strategy for Deployment
    type: RollingUpdate                 # Type of update strategy
    rollingUpdate:                      # Configurations for rolling updates
      maxSurge: 1                       # Allow 1 extra pod during update
      maxUnavailable: 1                 # Allow 1 pod to be unavailable during update

  selector:                             # Selector to match pods managed by this Deployment
    matchLabels:                        # Pods must contain these labels
      app: demo-app                     # Label selector

  template:                             # Pod template (same structure as a Pod spec)
    metadata:                           # Metadata for the pod template
      labels:                           # Labels applied to pods
        app: demo-app                   # Same label required for selector
      annotations:                      # Pod annotations
        checksum/config: "abc123"       # Example used for config reload triggers

    spec:                               # Pod specification
      serviceAccountName: demo-sa       # ServiceAccount used by pods
      hostAliases:                      # Adds custom entries to /etc/hosts
        - ip: "10.0.0.5"                # IP address to map
          hostnames:                    # List of hostnames mapped to IP
            - "internal-api.local"      # Example hostname

      imagePullSecrets:                 # Secrets for pulling private images
        - name: regcred                 # Docker registry secret name

      tolerations:                      # Allows pods to be scheduled on tainted nodes
        - key: "env"                    # Taint key to tolerate
          operator: "Equal"             # Comparison operator
          value: "dev"                  # Taint value to match
          effect: "NoSchedule"          # Taint effect this pod tolerates

      affinity:                         # Controls pod placement rules
        nodeAffinity:                   # Node-level affinity (where pods can run)
          requiredDuringSchedulingIgnoredDuringExecution:   # Hard requirement
            nodeSelectorTerms:          # List of rules that must match
              - matchExpressions:       # Match node labels
                  - key: node-type      # Node label key
                    operator: In        # Operator
                    values:             # Allowed values
                      - high-perf       # Example node type

          preferredDuringSchedulingIgnoredDuringExecution:  # Soft preference
            - weight: 1                 # Priority weight
              preference:               # Matching preference
                matchExpressions:       # Node label condition
                  - key: disk-type      # Label key
                    operator: In        # Operator
                    values:             # Preferred values
                      - ssd             # SSD preferred

        podAffinity:                    # Pods that must run near another pod
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:            # Select pods to co-locate with
                matchLabels:
                  app: backend          # Pods with label app=backend
              topologyKey: "kubernetes.io/hostname"  # Affinity based on node hostname

        podAntiAffinity:                # Pods that must NOT run on same node
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100               # Weight of anti-affinity preference
              podAffinityTerm:          # Rules for anti-affinity
                labelSelector:          # Select pods to avoid
                  matchLabels:
                    app: demo-app       # Avoid placing same app on same node
                topologyKey: "kubernetes.io/hostname"  # Node-level separation

      volumes:                          # Volumes made available to containers
        - name: config-volume           # Volume name
          configMap:                    # Mount content from ConfigMap
            name: demo-config           # ConfigMap name
        - name: tls-volume              # TLS certificate volume
          secret:                       # Secret-based volume
            secretName: tls-secret      # TLS Secret name
        - name: emptydir-volume         # Temporary pod-level storage
          emptyDir: {}                  # Creates emptyDir volume
        - name: hostpath-volume         # HostPath example (rarely used)
          hostPath:
            path: /var/log              # Host directory path
            type: Directory             # Ensure directory exists

      containers:                       # List of containers in the pod
        - name: main-app                # Primary application container
          image: nginx:latest           # Image used for the container
          imagePullPolicy: IfNotPresent # Image pull policy
          ports:                        # Container ports exposed
            - containerPort: 80         # Port exposed by nginx
          envFrom:                      # Load environment variables
            - configMapRef:             # From ConfigMap
                name: demo-config       # Name of ConfigMap
            - secretRef:                # From Secret
                name: app-secret        # Name of Secret

          env:                          # Individual environment vars
            - name: APP_ENV             # Environment variable name
              value: "production"       # Hardcoded value

          volumeMounts:                 # Mount volumes inside the container
            - name: config-volume       # Mount ConfigMap
              mountPath: /etc/nginx     # Directory inside container
            - name: tls-volume          # TLS secret volume
              mountPath: /etc/tls       # Where certificates are stored
            - name: emptydir-volume     # Temporary storage
              mountPath: /tmp/data      # Mounted path

          resources:                    # Resource limits & requests
            limits:                     # Max allowed
              cpu: "500m"               # CPU limit
              memory: "512Mi"           # Memory limit
            requests:                   # Minimum guaranteed
              cpu: "250m"               # CPU request
              memory: "256Mi"           # Memory request

          livenessProbe:                # Liveness probe checks if container is healthy
            httpGet:                    # HTTP-based probe
              path: /health             # Probe endpoint
              port: 80                  # Probe port
            initialDelaySeconds: 10     # Wait before first probe
            periodSeconds: 10           # Probe interval

          readinessProbe:               # Readiness probe (ready for traffic)
            httpGet:                    # HTTP-based probe
              path: /ready              # Probe endpoint
              port: 80                  # Probe port
            initialDelaySeconds: 5      # Wait before first probe
            periodSeconds: 5            # Probe interval

        - name: sidecar-logger           # Sidecar container example
          image: busybox                 # Simple BusyBox image
          command: ["sh", "-c"]          # Command to run inside container
          args: ["tail -n+1 -F /var/log/app.log"] # Follows log file
          volumeMounts:                  # Sidecar volume mounts
            - name: hostpath-volume      # Mounting hostPath
              mountPath: /var/log        # Log directory
```

---


