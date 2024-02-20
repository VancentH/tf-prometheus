#!/bin/bash

sudo tee /etc/prometheus/dead-mans-snitch-rule.yml >/dev/null <<'EOL'
---
groups:
- name: dead-mans-snitch
  rules:
  - alert: DeadMansSnitch
    annotations:
      message: This alert is integrated with DeadMansSnitch.
    expr: vector(1)
EOL
