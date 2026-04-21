#!/bin/bash

MOUNT_DIR="$HOME/s3-mount"
ROLE_NAME="S3MountpointDemoRole"
INSTANCE_PROFILE_NAME="S3MountpointDemoProfile"

if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  echo "Run:  export BUCKET_NAME=your-bucket-name"
  exit 1
fi

echo " S3 Mountpoint Demo - Cleanup"

# --- Step 1: Unmount (run on EC2 instance) ---
echo ""
echo "[1/4] Unmounting S3 from $MOUNT_DIR (if mounted)..."
if mountpoint -q "$MOUNT_DIR" 2>/dev/null; then
  fusermount -u "$MOUNT_DIR" && echo "    Unmounted." || echo "    Could not unmount — may need manual: sudo umount $MOUNT_DIR"
else
  echo "    Not mounted, skipping."
fi

# --- Step 2: Empty and delete the S3 bucket ---
echo ""
echo "[2/4] Emptying and deleting S3 bucket: $BUCKET_NAME"
aws s3 rm "s3://$BUCKET_NAME" --recursive
aws s3api delete-bucket --bucket "$BUCKET_NAME"
echo "    Bucket deleted."

# --- Step 3: Detach role from instance profile and delete ---
echo ""
echo "[3/4] Removing IAM instance profile..."
aws iam remove-role-from-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" \
  --role-name "$ROLE_NAME" 2>/dev/null || true

aws iam delete-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" 2>/dev/null || true
echo "    Instance profile deleted."

# --- Step 4: Delete IAM role and its inline policy ---
echo ""
echo "[4/4] Deleting IAM role: $ROLE_NAME"
aws iam delete-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "S3MountpointDemoPolicy" 2>/dev/null || true

aws iam delete-role --role-name "$ROLE_NAME" 2>/dev/null || true
echo "    IAM role deleted."


echo " Cleanup complete!"
echo "   aws ec2 terminate-instances --instance-ids <your-instance-id>"
