#!/bin/bash

set -e

# Variables
DOCKER_IMAGE="kathirganesan/books-api:latest"
TERRAFORM_DIR="./terraform"

# 1. Build the JAR
echo "1. Building Spring Boot JAR..."
./mvnw clean package -DskipTests

# 2. Build and push Docker image
echo "2. Building Docker image..."
docker build -t $DOCKER_IMAGE .

echo "3. Pushing image to Docker Hub..."
docker push $DOCKER_IMAGE

# 3. Apply Terraform
echo "4. Deploying infrastructure with Terraform..."
cd $TERRAFORM_DIR
terraform init
terraform apply -auto-approve -var-file="terraform.tfvars"

