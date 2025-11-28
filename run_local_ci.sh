#!/usr/bin/env bash
set -euo pipefail

IMAGE=fpga-actions-ci:local

echo "Building Docker image ${IMAGE}..."
docker build -t ${IMAGE} .

echo "Running tests inside Docker container..."
docker run --rm -v "$(pwd)":/workspace -w /workspace ${IMAGE}

echo "Done. If you want the script executable: chmod +x run_local_ci.sh"
