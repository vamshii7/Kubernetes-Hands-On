# Jobs & CronJobs — Kubernetes Deep Dive

## Overview
**Job** runs one-off tasks to completion. **CronJob** schedules jobs on a time-based schedule (like cron).

## How it fits in the cluster lifecycle
- Jobs create one or more Pods to complete work and then finish. CronJobs create Jobs on schedule.

## Core CLI Reference
- Apply Job/CronJob: `kubectl apply -f job.yaml`
- Get: `kubectl get jobs`, `kubectl get cronjobs`
- Describe: `kubectl describe job <name>`
- View logs: `kubectl logs job/<pod-name>`
- Delete: `kubectl delete job <name>`, `kubectl delete cronjob <name>`

## Explained YAML (fields to know)
- `spec.template` — pod template for the job
- `spec.completions` and `spec.parallelism` for Job concurrency
- `spec.schedule` in CronJob and `successfulJobsHistoryLimit`/`failedJobsHistoryLimit`

## Practical Use-Cases
- Database migrations, backup scripts, batch processing, ETL tasks

## Best Practices
- Set appropriate `backoffLimit` and `activeDeadlineSeconds`
- Use non-root containers for security
- Monitor job history retention to avoid resource explosion

## Troubleshooting Checklist
- Inspect job status for `Failed` or `Active` counts
- Check pod logs for the job to diagnose failure