#!/bin/bash
set -e

# Install Docker, Docker Compose, nginx, CloudWatch agent
apt update -y
apt install -y docker.io docker-compose nginx ufw curl unzip

# Start Docker
systemctl enable docker
systemctl start docker

# Create app directory
mkdir -p /opt/books-api
cd /opt/books-api

# Create docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3'
services:
  books-api:
    image: kathirganesan/books-api:latest
    container_name: books-api
    restart: always
    ports:
      - "8080:8080"
EOF

# Launch app with Docker Compose
docker-compose up -d

# Configure nginx reverse proxy
cat > /etc/nginx/sites-available/books-api <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/books-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

# Install CloudWatch Agent
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "/books-api",
            "log_stream_name": "{instance_id}/docker",
            "retention_in_days": 14
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/books-api",
            "log_stream_name": "{instance_id}/nginx-access"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/books-api",
            "log_stream_name": "{instance_id}/nginx-error"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

