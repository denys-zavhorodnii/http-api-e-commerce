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

# Detect the target platform from the remote host, so an arm64 build machine
# (Apple Silicon) doesn't ship an image the server can't exec.
echo "🔎 Detecting remote architecture..."
REMOTE_ARCH=$(ssh $REMOTE_USER@$REMOTE_HOST 'uname -m')
case "$REMOTE_ARCH" in
    x86_64|amd64)   PLATFORM="linux/amd64" ;;
    aarch64|arm64)  PLATFORM="linux/arm64" ;;
    *) echo "❌ Unsupported remote architecture: $REMOTE_ARCH"; exit 1 ;;
esac
echo "   Remote is $REMOTE_ARCH -> building for $PLATFORM"

# Build Docker image
echo "📦 Building Docker image..."
docker build --platform $PLATFORM -t $IMAGE_NAME:$TAG .

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

    # Run new container
    echo "Starting new container..."
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p 3010:3010 \
        -e NODE_ENV=production \
        -e PORT=3010 \
        -v $REMOTE_PATH/data:/app/data \
        $IMAGE_NAME:$TAG

    # Clean up
    rm /tmp/$IMAGE_NAME-$TAG.tar.gz

    # Verify the container is actually still alive a few seconds later:
    # a crash-on-startup container is "running" for the instant after docker run.
    echo "Waiting for container to settle..."
    sleep 5
    if [ "\$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" != "true" ]; then
        echo "❌ Container is not running. Exit code: \$(docker inspect -f '{{.State.ExitCode}}' $CONTAINER_NAME 2>/dev/null)"
        echo "----- container logs -----"
        docker logs --tail 50 $CONTAINER_NAME 2>&1 || true
        echo "--------------------------"
        exit 1
    fi

    # Verify the API actually answers
    echo "Checking health endpoint..."
    for i in 1 2 3 4 5 6 7 8 9 10; do
        if docker exec $CONTAINER_NAME node -e "require('http').get('http://127.0.0.1:3010/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"; then
            HEALTHY=1
            break
        fi
        sleep 2
    done
    if [ -z "\$HEALTHY" ]; then
        echo "❌ Container is running but /health never responded."
        docker logs --tail 50 $CONTAINER_NAME 2>&1 || true
        exit 1
    fi

    # Show container status
    echo "Container status:"
    docker ps --filter name=$CONTAINER_NAME

    echo "✅ Deployment completed successfully!"
EOF

# Clean up local tar file
rm $IMAGE_NAME-$TAG.tar.gz

echo "🎉 Deployment completed!"
echo "Your API is now running on $REMOTE_HOST:3010"
