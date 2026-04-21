#!/bin/bash
# ============================================================
# mount.sh - Mounts the S3 bucket as a local directory
# Run this ON your EC2 instance after install.sh
# ============================================================

set -e

# ---------- CONFIG ----------
MOUNT_DIR="$HOME/s3-mount"
# ----------------------------

# Bucket name must be set as an env variable
if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  echo "Run:  export BUCKET_NAME=your-bucket-name"
  exit 1
fi

echo "=========================================="
echo " Mounting S3 Bucket"
echo "=========================================="
echo ""
echo " Bucket    : $BUCKET_NAME"
echo " Mount dir : $MOUNT_DIR"
echo ""

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_DIR"

# Mount the bucket
# --allow-delete  : lets us delete files via the mount
# --allow-other   : allows other users to access the mount (optional)
mount-s3 "$BUCKET_NAME" "$MOUNT_DIR" --allow-delete

echo " Bucket mounted at: $MOUNT_DIR"
echo " You can now read/write files at: $MOUNT_DIR"
