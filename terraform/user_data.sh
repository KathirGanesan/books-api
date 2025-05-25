#!/bin/bash
set -e

# Install Docker, Docker Compose, nginx
apt update -y
apt install -y docker.io docker-compose nginx ufw

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

# Enable the site and disable default
ln -s /etc/nginx/sites-available/books-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Restart nginx
nginx -t && systemctl restart nginx
