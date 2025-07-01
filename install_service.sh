#!/usr/bin/env bash

set -e

echo "🔧 Creating systemd service for nginx..."

# Create the unit file
sudo tee /etc/systemd/system/nginx.service > /dev/null <<'EOF'
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable and start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo "✅ nginx.service created and started."

