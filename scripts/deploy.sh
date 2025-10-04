#!/bin/bash

# Deployment script for Docker container
# Usage: ./deploy.sh [TAG] [REMOTE_HOST] [REMOTE_USER]
# Example: ./deploy.sh latest my-server.com deploy

set -e

# Configuration
IMAGE_NAME="http-api-1"
TAG=${1:-latest}
REMOTE_HOST=${2:-"45.32.145.127"}
REMOTE_USER=${3:-"root"}
REMOTE_PATH="/opt/http-api-1"
CONTAINER_NAME="http-api-1"

echo "🚀 Starting deployment..."

# Build Docker image
echo "📦 Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

# Save image to tar file
echo "💾 Saving image to tar file..."
docker save $IMAGE_NAME:$TAG | gzip > $IMAGE_NAME-$TAG.tar.gz

# Upload to server
echo "📤 Uploading to server..."
scp $IMAGE_NAME-$TAG.tar.gz $REMOTE_USER@$REMOTE_HOST:/tmp/

# Deploy on server
echo "🔧 Deploying on server..."
ssh $REMOTE_USER@$REMOTE_HOST << EOF
    set -e
    
    # Load the image
    echo "Loading Docker image..."
    docker load < /tmp/$IMAGE_NAME-$TAG.tar.gz
    
    # Stop and remove existing container
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
    
    # Create data directory
    mkdir -p $REMOTE_PATH/data
    mkdir -p $REMOTE_PATH/database
    
    # Run new container
    echo "Starting new container..."
    docker run -d \
        --name $CONTAINER_NAME \
        -p 3010:3010 \
        $IMAGE_NAME:$TAG
    
    # Clean up
    rm /tmp/$IMAGE_NAME-$TAG.tar.gz
    
    # Show container status
    echo "Container status:"
    docker ps | grep $CONTAINER_NAME
    
    echo "✅ Deployment completed successfully!"
EOF

# Clean up local tar file
rm $IMAGE_NAME-$TAG.tar.gz

echo "🎉 Deployment completed!"
echo "Your API is now running on $REMOTE_HOST:3010"
