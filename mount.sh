#!/bin/bash

set -e

MOUNT_DIR="$HOME/s3-mount"

if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  echo "Run:  export BUCKET_NAME=your-bucket-name"
  exit 1
fi

echo " Mounting S3 Bucket"
echo " Bucket    : $BUCKET_NAME"
echo " Mount dir : $MOUNT_DIR"

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_DIR"

# Mount the bucket
# --allow-delete  : lets us delete files via the mount
# --allow-other   : allows other users to access the mount (optional)
mount-s3 "$BUCKET_NAME" "$MOUNT_DIR" --allow-delete

echo " Bucket mounted at: $MOUNT_DIR"
echo " You can now read/write files at: $MOUNT_DIR"
