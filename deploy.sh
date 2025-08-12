#!/bin/bash
set -e

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
