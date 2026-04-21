#!/bin/bash
# ============================================================
# test.sh - Writes files to the S3 mount and verifies them
# Run this ON your EC2 instance after mount.sh
# ============================================================

set -e

# ---------- CONFIG ----------
MOUNT_DIR="$HOME/s3-mount"
# ----------------------------

if [ -z "$BUCKET_NAME" ]; then
  echo "Error: BUCKET_NAME environment variable is not set."
  echo "Run:  export BUCKET_NAME=your-bucket-name"
  exit 1
fi

echo "=========================================="
echo " S3 Mountpoint Demo - Write & Verify"
echo "=========================================="

# --- Test 1: Write a simple text file ---
echo ""
echo "[Test 1] Writing a text file via the mount..."
echo "Hello from EC2! Written at $(date)" > "$MOUNT_DIR/hello.txt"
echo "    Written: $MOUNT_DIR/hello.txt"

# --- Test 2: Write a simulated log file ---
echo ""
echo "[Test 2] Writing a simulated log file..."
LOG_FILE="$MOUNT_DIR/app-$(date +%Y-%m-%d).log"
for i in {1..5}; do
  echo "[$(date +%T)] INFO - Event #$i processed successfully" >> "$LOG_FILE"
  sleep 0.2
done
echo "    Written: $LOG_FILE"

# --- Test 3: Write a JSON file ---
echo ""
echo "[Test 3] Writing a JSON config file..."
cat > "$MOUNT_DIR/config.json" <<EOF
{
  "demo": "s3-mountpoint",
  "instance": "$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo 'local')",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "message": "Written directly to S3 via Mountpoint"
}
EOF
echo "    Written: $MOUNT_DIR/config.json"

# --- Verify: List files in the mount ---
echo ""
echo "=========================================="
echo " Files visible in mount ($MOUNT_DIR):"
echo "=========================================="
ls -lh "$MOUNT_DIR"

# --- Verify: Confirm files exist in S3 ---
echo ""
echo "=========================================="
echo " Verifying files exist in S3 bucket:"
echo "=========================================="
aws s3 ls "s3://$BUCKET_NAME/" --human-readable

# --- Read back the text file ---
echo ""
echo "=========================================="
echo " Reading hello.txt back from the mount:"
echo "=========================================="
cat "$MOUNT_DIR/hello.txt"

echo ""
echo "=========================================="
echo " All tests passed!"
echo "=========================================="
echo ""
echo " Your files are now in S3 bucket: $BUCKET_NAME"
echo " Check them in the AWS Console or run:"
echo "   aws s3 ls s3://$BUCKET_NAME/"
echo ""
echo " Done! Run bash cleanup.sh when you're finished."
