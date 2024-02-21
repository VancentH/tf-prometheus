#!/bin/bash

# Open the Grafana datasource configuration file in vim
sudo vim /etc/grafana/provisioning/datasources/datasources.yaml <<EOL
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    isDefault: true # Set this to make it the default datasource
EOL
