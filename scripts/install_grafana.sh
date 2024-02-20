#!/bin/bash

# Install dependencies
sudo apt-get install -y apt-transport-https software-properties-common

# Add GPG key for Grafana software package
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add Grafana repository for stable releases to APT sources list
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update and install Grafana
sudo apt-get update
sudo apt-get -y install grafana

# Enable Grafana service to start automatically after reboot
sudo systemctl enable grafana-server

# Start Grafana
sudo systemctl start grafana-server

# Check the status of Grafana
sudo systemctl status grafana-server

# (Optional) Add Datasource
sudo tee /etc/grafana/provisioning/datasources/datasources.yaml >/dev/null <<'EOL'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    isDefault: true
EOL

# Restart Grafana
sudo systemctl restart grafana-server
