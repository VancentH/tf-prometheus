#!/bin/bash

# Create prometheus user and group
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false prometheus

# Download the latest version of Prometheus (replace version number accordingly)
wget https://github.com/prometheus/prometheus/releases/download/v2.45.3/prometheus-2.45.3.linux-amd64.tar.gz

# Unpack the tar.gz file
tar -xvf prometheus-2.45.3.linux-amd64.tar.gz

# Mount under the /data directory and create the prometheus folder
sudo mkdir -p /data /etc/prometheus

# Move prometheus binary and promtool to /usr/local/bin/
sudo mv prometheus promtool /usr/local/bin/

# Move console libraries to the Prometheus configuration directory
sudo mv consoles/ console_libraries/ /etc/prometheus/

# Move the example of the main prometheus configuration file
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Set correct ownership for /etc/prometheus/ and data directory
sudo chown -R prometheus:prometheus /etc/prometheus/ /data/

# Delete the archive and the Prometheus folder
rm -rf prometheus*

# Verify Prometheus version
prometheus --version

# Set up systemd and create a systemd unit configuration file for Prometheus

# Create the prometheus.service file using a heredoc
sudo tee /etc/systemd/system/prometheus.service >/dev/null <<'EOL'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
# ExecStart defines the command to start Prometheus with necessary options
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOL

# Notify systemd about the changes
# sudo systemctl daemon-reload

# Enable and start the Prometheus service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check the status of Prometheus service
sudo systemctl status prometheus
