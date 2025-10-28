# Notes on Node Affinity & Taints for kind

To simulate taints and affinity:
```bash
kubectl taint nodes <your-node-name> demo-taint=true:NoSchedule
```

Remove taint:
```bash
kubectl taint nodes <your-node-name> demo-taint=true:NoSchedule-
```

The pod will tolerate this taint and can still schedule successfully.
