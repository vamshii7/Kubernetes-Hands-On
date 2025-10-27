# Kubernetes Volumes & StorageClasses — Multi-Cloud Deep Dive (Azure & AWS)

## Overview
This pack explains Kubernetes persistent storage concepts and demonstrates **dynamic provisioning** using StorageClasses for **Azure (AKS)** and **AWS (EKS)**. It includes commented YAMLs for hands-on testing the provisioning flow.

**Warning:** The cloud examples require a functioning cluster on the respective cloud provider (AKS/EKS) with appropriate IAM/role bindings and CSI drivers installed. Do **not** apply these manifests on Kind unless you adapt them for local testing and have corresponding drivers.

---

## Contents
- `azure-disk-storageclass.yaml` — StorageClass (Azure Disk CSI) + example PVC
- `azure-file-storageclass.yaml` — StorageClass (Azure File CSI) + example PVC
- `aws-ebs-storageclass.yaml` — StorageClass (AWS EBS CSI) + example PVC
- `aws-efs-storageclass.yaml` — StorageClass (AWS EFS CSI) + example PVC
- `pod-using-pvc.yaml` — Generic Pod example that mounts a PVC

---

## Key Concepts Recap

- **PV (PersistentVolume):** cluster resource backed by storage (cloud disk, NFS, etc.).
- **PVC (PersistentVolumeClaim):** a user's request for storage (size, access mode, StorageClass).
- **StorageClass:** defines the provisioner and parameters for dynamic provisioning (e.g., `provisioner: disk.csi.azure.com`).
- **Dynamic provisioning:** when a PVC is created with a `storageClassName`, the cluster will ask the provisioner to create a PV automatically.
- **Reclaim policy:** controls what happens to PV after PVC deletion (`Delete` or `Retain`).

---

## How to test (general steps)
1. Ensure your cluster has the correct CSI drivers and cloud provider integration (AKS/EKS). For AKS, the Azure Disk/File CSI are usually preinstalled (or can be installed via helm/manifests). For EKS, install AWS EBS CSI and EFS CSI as required.
2. Create a namespace for testing:
   ```bash
   kubectl create namespace k8s-storage-test
   ```
3. Apply a StorageClass and PVC in that namespace:
   ```bash
   kubectl apply -f azure-disk-storageclass.yaml -n k8s-storage-test
   kubectl apply -f pod-using-pvc.yaml -n k8s-storage-test
   ```
4. Verify PVC and PV binding:
   ```bash
   kubectl get pvc -n k8s-storage-test
   kubectl get pv
   ```

---

## Notes
- StorageClass parameters vary across cloud providers (zones, replication, fsType). Consult the provider CSI docs before using in production.
- For AWS EFS, provisioning also requires creating/accessing a filesystem and mounting targets in the target VPC/subnets.
- Azure File provides SMB-like file shares across nodes and supports RWX in many cases depending on SKU.

---
**Author:** Vamshi Krishna
**Use:** Educational / Lab purposes. Review and adapt for your production policies and security controls.