#!/bin/bash

# Add user and group for Pushgateway
sudo useradd \
    --system \
    --no-create-home \
    --shell /bin/false pushgateway

# Download Pushgateway (replace version number accordingly)
wget https://github.com/prometheus/pushgateway/releases/download/v1.7.0/pushgateway-1.7.0.linux-amd64.tar.gz

# Unpack the tar.gz file
tar -xvf pushgateway-1.7.0.linux-amd64.tar.gz

# Move the Pushgateway binary to /usr/local/bin (installation)
sudo mv pushgateway-1.7.0.linux-amd64/pushgateway /usr/local/bin/

# Remove the extracted folder
rm -rf pushgateway*

# List contents of the directory
ls

# Verify Pushgateway version
pushgateway --version

# Create systemd service for Pushgateway
sudo tee /etc/systemd/system/pushgateway.service >/dev/null <<'EOL'
[Unit]
Description=Pushgateway
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=pushgateway
Group=pushgateway
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/pushgateway

[Install]
WantedBy=multi-user.target
EOL

# Enable the Pushgateway service
sudo systemctl enable pushgateway

# Start Pushgateway
sudo systemctl start pushgateway

# Check the status of Pushgateway
sudo systemctl status pushgateway
