#!/bin/bash

set -e

MOUNT_DIR="$HOME/s3-mount"

if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  echo "Run:  export BUCKET_NAME=your-bucket-name"
  exit 1
fi

echo " S3 Mountpoint Demo - Write & Verify"

echo ""
echo "Writing a text file via the mount..."
echo "Hello from EC2! Written at $(date)" > "$MOUNT_DIR/hello.txt"
echo "    Written: $MOUNT_DIR/hello.txt"

