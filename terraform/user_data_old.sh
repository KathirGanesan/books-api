#!/bin/bash
set -e

# Install Docker
apt update -y
apt install -y docker.io docker-compose nginx ufw

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Pull Docker image (replace with your Docker Hub username)
docker pull kathirganesan/books-api:latest

# Run the container
docker run -d \
  --restart always \
  --name books-api \
  -p 8080:8080 \
  kathirganesan/books-api:latest

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
rm /etc/nginx/sites-enabled/default
systemctl restart nginx
