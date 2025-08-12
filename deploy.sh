#!/bin/bash
set -e

echo "🚀 Updating system packages..."
sudo apt-get update -y

echo "📦 Installing dependencies..."
sudo apt-get install -y docker.io git openjdk-17-jdk maven

echo "🐳 Ensuring Docker is running..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

echo "📂 Navigating to project directory..."
cd "$(dirname "$0")"

echo "🚀 Building Spring Boot app..."
mvn clean package -DskipTests

echo "🐳 Building Docker image..."
docker build -t springboot-cicd-demo:latest .

echo "🛑 Stopping old container (if exists)..."
docker stop springboot-demo-container || true
docker rm springboot-demo-container || true

echo "▶️ Starting new container..."
docker run -d --name springboot-demo-container -p 8080:8080 springboot-cicd-demo:latest

echo "✅ Deployment completed successfully!"
