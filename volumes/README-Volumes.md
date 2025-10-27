# Persistent Volumes & Volume Types — Kubernetes Deep Dive

## Overview
Kubernetes Volumes provide **persistent or ephemeral storage** to containers. 
While containers are ephemeral, volumes ensure that data can persist across restarts or be shared between containers in a Pod.

### Core Concepts
- **Volume**: Storage attached to a Pod; lifecycle tied to Pod (unless PVC used).
- **PersistentVolume (PV)**: Cluster-wide resource representing physical storage.
- **PersistentVolumeClaim (PVC)**: Request for storage by users/pods.
- **StorageClass**: Defines how storage is dynamically provisioned.

---

## Volume Types and Usage

| Volume Type | Description | Example Use Case |
|--------------|--------------|------------------|
| **emptyDir** | Temporary directory shared between containers in a Pod. Deleted when Pod is removed. | Caching, scratch space |
| **hostPath** | Mounts a file or directory from the host node’s filesystem. | Single-node dev testing, local logs |
| **configMap** | Mounts data from a ConfigMap as files or env vars. | App configuration |
| **secret** | Mounts sensitive data like passwords or certs. | Secure credentials |
| **nfs** | Mounts a Network File System. | Shared storage for multiple Pods |
| **persistentVolumeClaim** | Mounts dynamically or statically provisioned PVs. | Databases, StatefulSets |
| **awsElasticBlockStore / azureFile / gcePersistentDisk** | Cloud provider-managed persistent disks. | Production workloads in cloud |
| **ephemeral (CSI ephemeral)** | Dynamically provisioned short-lived volumes. | CI/CD scratch volumes |

---

## Access Modes
| Mode | Description | Example |
|------|--------------|----------|
| **ReadWriteOnce (RWO)** | Mounted read-write by a single node. | Most databases |
| **ReadOnlyMany (ROX)** | Mounted read-only by multiple nodes. | Shared dataset |
| **ReadWriteMany (RWX)** | Mounted read-write by multiple nodes. | Shared file systems |
| **ReadWriteOncePod (RWOP)** | Mounted read-write by a single Pod only. | Newer strict mode for security |

---

## Lifecycle and Binding
1. **Admin creates PVs** or defines a `StorageClass` for dynamic provisioning.
2. **User creates PVCs**, which are bound to matching PVs.
3. Pods reference the PVCs in their spec.
4. When PVC is deleted, reclaim policy decides what happens to the PV (`Retain`, `Delete`, `Recycle`).

---

## Example CLI Commands
```bash
kubectl get pv,pvc
kubectl describe pv <name>
kubectl describe pvc <name>
kubectl get sc
kubectl delete pvc <name>
```

---

## Best Practices
- Use **StorageClasses** with dynamic provisioning for flexibility.
- Avoid `hostPath` in production clusters.
- Use **ReadWriteMany** volumes only when necessary (can reduce performance).
- Set `persistentVolumeReclaimPolicy: Retain` for critical data.
- Regularly monitor PVC status to avoid stuck `Pending` claims.

---

## Troubleshooting
- **PVC stuck Pending**: No matching PV or missing StorageClass.
- **Mount errors**: Verify filesystem permissions.
- **Access mode mismatch**: Ensure PV supports the requested mode.
- Use `kubectl get events -n <ns>` and `kubectl describe pod <name>` for debug info.

---

## Example Volume Types (YAMLs)
See YAML examples alongside this README:
- `emptydir-pod.yaml`
- `hostpath-pod.yaml`
- `configmap-volume.yaml`
- `secret-volume.yaml`
- `nfs-volume.yaml`
- `pv.yaml`, `pvc.yaml`, `storageclass.yaml`, `pod-using-pvc.yaml`

---

## Diagram: PV-PVC Binding Flow

```
        +------------------------+
        |   Pod (nginx)          |
        |------------------------|
        | volumeMounts: mypvc    |
        +-----------|------------+
                    |
                    v
        +------------------------+
        | PersistentVolumeClaim  |
        | - storageClass: fast   |
        | - size: 5Gi            |
        +-----------|------------+
                    |
                    v
        +------------------------+
        | PersistentVolume (PV)  |
        | - path: /mnt/data      |
        | - capacity: 5Gi        |
        +------------------------+
```

---