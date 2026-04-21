#!/bin/bash
# ============================================================
# install.sh - Installs Mountpoint for Amazon S3 on EC2
# Run this ON your EC2 instance (Amazon Linux 2023 / Ubuntu)
# ============================================================

set -e

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Cannot detect OS. Exiting."
  exit 1
fi

echo ""
echo "Detected OS: $OS"

if [[ "$OS" == "amzn" || "$OS" == "rhel" || "$OS" == "centos" ]]; then
  # Amazon Linux / RHEL / CentOS
  echo ""
  echo "[1/2] Downloading Mountpoint RPM package..."
  wget -q https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm

  echo "[2/2] Installing..."
  sudo yum install -y ./mount-s3.rpm
  rm -f mount-s3.rpm

elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
  # Ubuntu / Debian
  echo ""
  echo "[1/2] Downloading Mountpoint DEB package..."
  wget -q https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb

  echo "[2/2] Installing..."
  sudo apt-get install -y ./mount-s3.deb
  rm -f mount-s3.deb

else
  echo "Unsupported OS: $OS"
  echo "See https://github.com/awslabs/mountpoint-s3 for manual install."
  exit 1
fi

echo " Mountpoint installed successfully!"
