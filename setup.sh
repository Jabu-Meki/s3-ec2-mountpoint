#!/bin/bash
# ============================================================
# setup.sh - Creates the S3 bucket and IAM role for the demo
# Run this from your LOCAL machine (not the EC2 instance)
# ============================================================

set -e

export BUCKET_NAME="s3-mountpoint-$(openssl rand -hex 4)"
export REGION="af-south-1"
export ROLE_NAME="S3MountpointDemoRole"
export INSTANCE_PROFILE_NAME="S3MountpointProfile"


# 1. Create S3 bucket
echo "[1/4] Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  $([ "$REGION" != "us-east-1" ] && echo "--create-bucket-configuration LocationConstraint=$REGION")

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "    Bucket created."

# 2. Create IAM role trust policy (for EC2)
echo ""
echo "[2/4] Creating IAM role: $ROLE_NAME"
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file:///tmp/trust-policy.json \
  --description "Role for S3 Mountpoint" \
  --output text --query 'Role.RoleName'

# 3. Attach inline policy scoped to just this bucket
echo "[3/4] Attaching S3 permissions policy"
cat > /tmp/s3-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:HeadBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME",
        "arn:aws:s3:::$BUCKET_NAME/*"
      ]
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "S3MountpointPolicy" \
  --policy-document file:///tmp/s3-policy.json

# 4. Create instance profile and attach role
echo ""
echo "[4/4] Creating instance profile and attaching role"
aws iam create-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" \
  --output text --query 'InstanceProfile.InstanceProfileName'

aws iam add-role-to-instance-profile \
  --instance-profile-name "$INSTANCE_PROFILE_NAME" \
  --role-name "$ROLE_NAME"


echo " Setup complete!"
echo " Bucket Name : $BUCKET_NAME"
echo " IAM Role    : $ROLE_NAME"
echo " Profile     : $INSTANCE_PROFILE_NAME"
echo " Region      : $REGION"
echo ""
echo " NEXT STEPS:"
echo " 1. Launch an EC2 instance and attach the instance profile: $INSTANCE_PROFILE_NAME"
echo " 2. SSH into the instance"
echo " 3. Run:  export BUCKET_NAME=$BUCKET_NAME"
echo " 4. Run:  bash install.sh"
echo " 5. Run:  bash mount.sh"
echo " 6. Run:  bash test.sh"
echo ""
echo " Save your bucket name: $BUCKET_NAME"
