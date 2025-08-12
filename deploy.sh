#!/bin/bash
set -e
sudo apt-get update -y
sudo apt-get install -y docker.io git openjdk-17-jdk maven
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

APP_DIR="springboot-cicd-demo"
REPO_URL="https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git"
DOCKER_IMAGE="springboot-cicd-demo"
DOCKER_TAG="latest"
CONTAINER_NAME="springboot-demo-container"

if [ ! -d "$APP_DIR" ]; then
    git clone "$REPO_URL" "$APP_DIR"
else
    cd "$APP_DIR" && git pull
fi

cd "$APP_DIR"
mvn clean package -DskipTests
docker stop "$CONTAINER_NAME" || true
docker rm "$CONTAINER_NAME" || true
docker build -t "$DOCKER_IMAGE:$DOCKER_TAG" .
docker run -d --name "$CONTAINER_NAME" -p 8085:8080 "$DOCKER_IMAGE:$DOCKER_TAG"
