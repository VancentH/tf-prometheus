#!/bin/bash

# Create user and group for Node Exporter
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false node_exporter

# Download Node Exporter (replace version number accordingly)
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# Unpack the tar.gz file
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz

# Move the binary to /usr/local/bin (installation)
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# Remove the extracted folder
rm -rf node_exporter*

# List contents of the directory
ls

# Verify Node Exporter version
node_exporter --version

# Node Exporter has various plugins that can be enabled
# This command is kept for reference but removed as per request
# node_exporter --help

# Create systemd unit configuration file
sudo tee /etc/systemd/system/node_exporter.service >/dev/null <<'EOL'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Node Exporter service
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check the status of Node Exporter
sudo systemctl status node_exporter
