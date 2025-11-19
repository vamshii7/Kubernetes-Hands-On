# Pods Kubernetes Deep Dive

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

## This is an example of Fully Loaded Pod Spec

### This YAML includes every feature a Pod can possibly take:  
- ✔ TLS Secret
- ✔ Pull Secrets
- ✔ Sidecar
- ✔ Init Containers
- ✔ All major volume types
- ✔ NodeSelector + NodeAffinity + PodAffinity + AntiAffinity
- ✔ Tolerations
- ✔ HostAliases
- ✔ Topology Spread Constraints
- ✔ Security Context
- ✔ Probes
- ✔ Resource Limits
- ✔ Private registry pull
- ✔ Priority class
- ✔ DNS Policy
- ✔ Custom scheduler

```yaml
apiVersion: v1                                                # Kubernetes API version.
kind: Pod                                                     # Pod object type.

metadata:                                                     # Identifying metadata for the Pod.
  name: comprehensive-pod-example                             # Unique Pod name.
  labels:                                                     # Labels for selection & grouping.
    app: multi-container-app                                  # App label.
    tier: backend                                             # Tier label.
  annotations:                                                # Non-identifying metadata.
    build-info: "v1.0.0, commit: abcdef12345"                 # Build-related annotations.

spec:                                                         # Pod desired state and configuration.
  serviceAccountName: app-service-account                     # ServiceAccount for RBAC permissions.

  imagePullSecrets:                                           # Secret for pulling images from private registries.
    - name: regcred                                           # Docker registry secret.

  hostAliases:                                                # Custom hostname mappings inside the Pod.
    - ip: "10.1.1.5"                                          # IP address.
      hostnames:
        - "internal.service.local"                            # Hostname mapping.

  tolerations:                                                # Allow scheduling on tainted nodes.
    - key: "critical-service"                                 
      operator: "Exists"                                     
      effect: "NoExecute"                                    
      tolerationSeconds: 600                                  

  containers:                                                 # List of containers inside the Pod.

    - name: app-container                                     # Main application container.
      image: nginx:1.21                                       # Container image.

      ports:                                                  # Ports exposed by container.
        - containerPort: 80                                   # HTTP port.
          name: http                                          # Named port.
          protocol: TCP                                       # Protocol.

      env:                                                    # Environment variables.
        - name: LOG_LEVEL
          value: INFO                                         # Static value.
        - name: DATABASE_HOST                                 # Inject from ConfigMap.
          valueFrom:
            configMapKeyRef:
              name: app-config                                # ConfigMap name.
              key: db_host                                    # Key inside ConfigMap.

      volumeMounts:                                           # Mount volumes into container.
        - name: shared-data
          mountPath: /usr/share/nginx/html                    # Nginx web root.
        - name: tls-secret-volume
          mountPath: /etc/tls                                 # TLS certificates path.
          readOnly: true

      resources:                                              # Resource limits & requests.
        limits:
          memory: "256Mi"
          cpu: "500m"
        requests:
          memory: "128Mi"
          cpu: "250m"

      livenessProbe:                                          # Liveness probe—checks container health.
        httpGet:
          path: /healthz
          port: 80
        initialDelaySeconds: 15                               
        periodSeconds: 20                                     

      readinessProbe:                                         # Readiness probe—checks if ready for traffic.
        httpGet:
          path: /ready
          port: 80
        initialDelaySeconds: 5                                
        periodSeconds: 10                                     

    - name: log-sidecar                                       # Sidecar for log shipping.
      image: fluentd:latest                                   # Fluentd logging agent.
      volumeMounts:
        - name: shared-data                                   # Access shared data/log files.
          mountPath: /logs

  initContainers:                                             # Init containers run before main containers.
    - name: init-myservice                                    
      image: busybox:1.28                                     
      command: ['sh', '-c', 'echo "Performing setup tasks..." && sleep 2']

  volumes:                                                    # Volumes available in the Pod.

    - name: shared-data                                       # Temporary storage shared across containers.
      emptyDir: {}                                            

    - name: tls-secret-volume                                 # TLS secret mount.
      secret:
        secretName: tls-secret                                # TLS Secret name.

    - name: config-volume                                     # ConfigMap as a volume.
      configMap:
        name: app-config

    - name: local-volume                                      # HostPath example volume.
      hostPath:
        path: /var/log/app                                    # Maps a host directory.
        type: DirectoryOrCreate

    - name: pvc-storage                                       # Persistent Volume Claim.
      persistentVolumeClaim:
        claimName: app-pvc                                    # PVC name.

  restartPolicy: Always                                       # Restart containers whenever they exit.

  nodeSelector:                                               # Simple node selection.
    environment: production                                   # Must run on production nodes.

  nodeAffinity:                                               # Advanced node placement rules.
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: disktype
              operator: In
              values:
                - ssd                                         # Must run on nodes with SSD.

  affinity:                                                   # Pod affinity & anti-affinity.
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - multi-container-app
          topologyKey: kubernetes.io/hostname                 # Co-locate with matching Pods.

    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app: multi-container-app
            topologyKey: kubernetes.io/hostname               # Spread Pods across nodes.

  securityContext:                                            # Pod-level security settings.
    runAsUser: 1000                                           # User ID.
    fsGroup: 2000                                             # Group ID for mounted volumes.

  terminationGracePeriodSeconds: 30                           # Graceful shutdown window.

  dnsPolicy: ClusterFirst                                     # Use cluster DNS.

  hostNetwork: false                                          # Do NOT share host network namespace.

  shareProcessNamespace: false                                # Do NOT share processes between containers.

  schedulerName: default-scheduler                            # Use default scheduler.

  enableServiceLinks: true                                    # Inject service env variables.

  priorityClassName: high-priority                            # High scheduling priority.

  topologySpreadConstraints:                                  # Distribute Pods evenly.
    - maxSkew: 1
      topologyKey: failure-domain.beta.kubernetes.io/zone     # Spread across zones.
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app: full-demo
          tier: backend
```

---
