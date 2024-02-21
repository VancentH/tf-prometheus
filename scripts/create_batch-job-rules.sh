#!/bin/bash

# Open the Prometheus batch job rules configuration file in vim
sudo vim /etc/prometheus/batch-job-rules.yml <<EOL
---
groups:
- name: batch-job-rules
  rules:
  - alert: JenkinsJobExceededThreshold
    annotations:
      message: Jenkins job exceeded a threshold of 30 seconds.
    expr: jenkins_job_duration_seconds{job="backup"} > 30
    for: 1m
    labels:
      severity: warning
EOL
