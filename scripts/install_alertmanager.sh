#!/bin/bash

# Add user and group for Alertmanager
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false alertmanager

# Download and install Alertmanager (replace version number accordingly)
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz

# Unpack the tar.gz file
tar -xvf alertmanager-0.26.0.linux-amd64.tar.gz

# Create storage space for Alertmanager (mandatory for storing notification states and silences)
# Default storage is in /data; this command ensures the directory exists
sudo mkdir -p /alertmanager-data /etc/alertmanager

# Move Alertmanager binary to /usr/local/bin and copy sample configuration file
sudo mv alertmanager-0.26.0.linux-amd64/alertmanager /usr/local/bin/
sudo mv alertmanager-0.26.0.linux-amd64/alertmanager.yml /etc/alertmanager/

# Remove the extracted folder
rm -rf alertmanager*

# Display Alertmanager version
alertmanager --version

# Create systemd service for Alertmanager
sudo tee /etc/systemd/system/alertmanager.service >/dev/null <<'EOL'
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=alertmanager
Group=alertmanager
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/alertmanager \
  --storage.path=/alertmanager-data \
  --config.file=/etc/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the Alertmanager service
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Check the status of Alertmanager
sudo systemctl status alertmanager
