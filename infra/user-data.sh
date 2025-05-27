#!/bin/bash
set -e

apt update -y
apt install -y docker.io

systemctl enable docker
systemctl start docker

# Pull the latest image
docker pull ghost:latest

# Run the Ghost container
docker run -d --name ghost -p 2368:2368 ghost:latest
