#!/bin/bash

# Define the base image name
IMAGE_NAME="tools-container"

# Get the current date in MMDDYY format
DATE_TAG=$(date +'%m%d%y')

# Initialize tag
TAG="v$DATE_TAG"

# Check if an image with the current tag already exists and increment suffix if it does
SUFFIX=0
while docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:${TAG}$"; do
  ((SUFFIX++))
  TAG="${DATE_TAG}_${SUFFIX}"
done

# Build the Docker image with the generated tag
docker build -t ${IMAGE_NAME}:${TAG} .

# Tag the image as "latest"
docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest

# Output the tags used
echo "Image built and tagged as:"
echo "${IMAGE_NAME}:${TAG}"
echo "${IMAGE_NAME}:latest"
