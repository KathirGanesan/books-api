#!/bin/bash
set -e

###############################################################################
# 0. Basic packages
###############################################################################
apt update -y
apt install -y docker.io docker-compose nginx ufw curl unzip

systemctl enable docker
systemctl start  docker

###############################################################################
# 1. Docker Compose stack  (backend + frontend)
###############################################################################
mkdir -p /opt/books-stack
cd /opt/books-stack

cat > docker-compose.yml <<'EOF'
version: "3.8"

services:
  books-api:
    image: kathirganesan/books-api:latest
    container_name: books-api
    restart: always
    ports:
      - "8080:8080"

  books-ui:
    image: kathirganesan/books-ui:latest      # <- your React-UI image tag
    container_name: books-ui
    restart: always
    ports:
      - "8081:80"                             # UI container listens on 80
EOF

docker-compose up -d

###############################################################################
# 2. Nginx reverse-proxy (Option A-style Swagger paths)
###############################################################################
cat > /etc/nginx/sites-available/books.conf <<'EOF'
server {
    listen 80;
    server_name books.zenflixapp.online;

    # ---- Swagger JSON -------------------------------------------------------
    location = /v3/api-docs         { proxy_pass http://127.0.0.1:8080/v3/api-docs; }
    location /v3/api-docs/          { proxy_pass http://127.0.0.1:8080/v3/api-docs/; }

    # ---- Swagger UI ---------------------------------------------------------
    location = /swagger-ui.html     { proxy_pass http://127.0.0.1:8080/swagger-ui.html; }
    location /swagger-ui/           { proxy_pass http://127.0.0.1:8080/swagger-ui/; }

    # ---- Backend REST API ---------------------------------------------------
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # ---- React SPA ----------------------------------------------------------
    location / {
        proxy_pass http://127.0.0.1:8081/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable site, disable default
ln -sf /etc/nginx/sites-available/books.conf /etc/nginx/sites-enabled/books.conf
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl restart nginx


###############################################################################
# 3. CloudWatch agent (unchanged)
###############################################################################
cd /tmp
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

mkdir -p /opt/aws/amazon-cloudwatch-agent/bin
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
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

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

