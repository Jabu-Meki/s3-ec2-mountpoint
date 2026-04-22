# S3 EC2 Mountpoint Demo

This project shows how to mount an Amazon S3 bucket on an EC2 instance by using Mountpoint for Amazon S3.

The repo gives you a simple end-to-end workflow:

- Create an S3 bucket and a least-privilege IAM role.
- Attach that role to an EC2 instance through an instance profile.
- Install Mountpoint for Amazon S3 on the instance.
- Mount the bucket to a local directory.
- Write a test file through the mount.
- Clean up the bucket and IAM resources when you are done.

## Architecture

The flow looks like this:

1. `setup.sh` runs on your local machine.
2. It creates:
   - An S3 bucket in `af-south-1`
   - An IAM role named `S3MountpointDemoRole`
   - An inline IAM policy named `S3MountpointDemoPolicy`
   - An instance profile named `S3MountpointDemoProfile`
3. You launch or update an EC2 instance and attach `S3MountpointDemoProfile`.
4. On the EC2 instance, `install.sh` installs Mountpoint for Amazon S3.
5. `mount.sh` mounts the bucket at `~/s3-mount`.
6. `test.sh` writes a test file through the mounted path.

## Repository Contents

- [setup.sh](./setup.sh) creates the S3 bucket, IAM role, policy, and instance profile.
- [install.sh](./install.sh) installs Mountpoint for Amazon S3 on Ubuntu, Debian, Amazon Linux, RHEL, and CentOS.
- [mount.sh](./mount.sh) mounts the S3 bucket into `~/s3-mount`.
- [test.sh](./test.sh) writes a sample file to verify the mount works.
- [cleanup.sh](./cleanup.sh) unmounts the bucket, deletes the bucket contents, and removes the IAM resources created for the demo.

## Prerequisites

Before you start, make sure you have:

- An AWS account with permission to create S3 buckets, IAM roles, IAM policies, and instance profiles.
- AWS CLI installed and configured on your local machine.
- An EC2 instance running Ubuntu, Debian, Amazon Linux, RHEL, or CentOS.
- Permission to attach an IAM instance profile to that EC2 instance.
- Network access from the EC2 instance to AWS S3 endpoints.

## AWS Permissions Needed

Your local AWS identity needs enough permission to run the setup and cleanup scripts. At minimum, that usually means access to:

- `s3:CreateBucket`
- `s3:DeleteBucket`
- `s3:PutPublicAccessBlock`
- `s3:ListBucket`
- `s3:DeleteObject`
- `iam:CreateRole`
- `iam:DeleteRole`
- `iam:PutRolePolicy`
- `iam:DeleteRolePolicy`
- `iam:CreateInstanceProfile`
- `iam:DeleteInstanceProfile`
- `iam:AddRoleToInstanceProfile`
- `iam:RemoveRoleFromInstanceProfile`
- `ec2:AssociateIamInstanceProfile` or console access to attach the profile

## What The Setup Script Creates

When you run [setup.sh](./setup.sh), it creates the following resources:

- A unique S3 bucket named like `s3-mountpoint-xxxxxxxx`
- IAM role: `S3MountpointDemoRole`
- IAM instance profile: `S3MountpointDemoProfile`
- IAM inline policy: `S3MountpointDemoPolicy`
- Region: `af-south-1`

The generated IAM policy is scoped to one bucket:

- Bucket-level permissions:
  - `s3:ListBucket`
  - `s3:HeadBucket`
- Object-level permissions:
  - `s3:GetObject`
  - `s3:PutObject`
  - `s3:DeleteObject`

## Quick Start

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd S3-EC-Mount
chmod +x *.sh
```

### 2. Run setup from your local machine

Do not run this step on the EC2 instance.

```bash
bash setup.sh
```

Example output:

```text
Bucket Name : s3-mountpoint-007fd2e4
IAM Role    : S3MountpointDemoRole
Profile     : S3MountpointDemoProfile
Policy      : S3MountpointDemoPolicy
Region      : af-south-1
```

Save the bucket name from the output. You will use it on the EC2 instance.

### 3. Launch or update your EC2 instance

Attach the instance profile `S3MountpointDemoProfile` to the EC2 instance.

If the instance is already running, you can attach the IAM role through:

- The AWS Console
- The AWS CLI

Make sure the EC2 instance is in a state where the role attachment has propagated before continuing. A short wait of around 30 to 90 seconds is often enough.

### 4. Connect to the EC2 instance

SSH into the instance:

```bash
ssh -i /path/to/key.pem ubuntu@<ec2-public-ip>
```

### 5. Set the bucket name on the EC2 instance

Use the bucket name printed by `setup.sh`:

```bash
export BUCKET_NAME=s3-mountpoint-007fd2e4
```

You can confirm it is set:

```bash
echo "$BUCKET_NAME"
```

### 6. Install Mountpoint for Amazon S3

Run this on the EC2 instance:

```bash
bash install.sh
```

This script detects the OS and installs either:

- `mount-s3.deb` for Ubuntu and Debian
- `mount-s3.rpm` for Amazon Linux, RHEL, and CentOS

### 7. Mount the S3 bucket

Run:

```bash
bash mount.sh
```

This mounts the bucket to:

```text
~/s3-mount
```

### 8. Verify by writing a file

Run:

```bash
bash test.sh
```

This writes a file called `hello.txt` into the mounted directory:

```text
~/s3-mount/hello.txt
```

### 9. Confirm the object exists in S3

From the EC2 instance or your local machine:

```bash
aws s3 ls "s3://$BUCKET_NAME/"
```

You should see `hello.txt`.

## Detailed Usage

### `setup.sh`

Purpose:

- Creates the S3 bucket
- Blocks all public access on the bucket
- Creates the EC2 trust policy
- Creates the IAM role and inline S3 access policy
- Creates the instance profile and adds the role to it

Run from:

- Your local machine

Important variables inside the script:

- `BUCKET_NAME`
- `REGION`
- `ROLE_NAME`
- `INSTANCE_PROFILE_NAME`
- `POLICY_NAME`

### `install.sh`

Purpose:

- Detects the OS on the EC2 instance
- Downloads the correct Mountpoint package
- Installs it using the system package manager

Run from:

- The EC2 instance

### `mount.sh`

Purpose:

- Checks that `BUCKET_NAME` is set
- Creates `~/s3-mount` if needed
- Runs `mount-s3` against the configured bucket

Run from:

- The EC2 instance

Mounted path:

- `~/s3-mount`

### `test.sh`

Purpose:

- Writes a sample file through the mounted filesystem

Run from:

- The EC2 instance

### `cleanup.sh`

Purpose:

- Unmounts the mounted directory if it is mounted
- Deletes all objects in the S3 bucket
- Deletes the bucket itself
- Removes the role from the instance profile
- Deletes the instance profile, policy, and role

Run from:

- Usually your local machine after the demo is complete

Notes:

- If the mount is still active on the EC2 instance, the unmount step is only effective if you run it on that EC2 host.
- The cleanup script requires `BUCKET_NAME` to still be exported.

## Example End-to-End Session

Local machine:

```bash
git clone <your-repo-url>
cd S3-EC-Mount
chmod +x *.sh
bash setup.sh
```

EC2 instance:

```bash
export BUCKET_NAME=s3-mountpoint-007fd2e4
bash install.sh
bash mount.sh
bash test.sh
ls -l ~/s3-mount
aws s3 ls "s3://$BUCKET_NAME/"
```

Cleanup:

```bash
export BUCKET_NAME=s3-mountpoint-007fd2e4
bash cleanup.sh
```

## Troubleshooting

### Error: `BUCKET_NAME environment variable is not set`

Cause:

- The shell session does not have the bucket name exported.

Fix:

```bash
export BUCKET_NAME=<your-bucket-name>
```

### Error: `not authorized to perform: s3:ListBucket`

Cause:

- The EC2 instance is using the wrong IAM role, or the attached role does not have access to the target bucket.

Fix:

- Confirm the instance is using `S3MountpointDemoProfile`, or another role with equivalent S3 permissions.
- Confirm the policy includes:
  - `s3:ListBucket` on `arn:aws:s3:::<bucket-name>`
  - `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on `arn:aws:s3:::<bucket-name>/*`

Helpful checks:

```bash
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
aws sts get-caller-identity
aws s3api list-objects-v2 --bucket "$BUCKET_NAME" --region af-south-1
```

### Mount command fails immediately

Cause:

- Mountpoint is not installed, the IAM role is missing, or the bucket region is wrong.

Fix:

- Re-run `bash install.sh`
- Confirm the EC2 instance profile is attached
- Confirm the bucket exists in `af-south-1`

### File writes do not appear in S3

Cause:

- The bucket may not be mounted successfully, or the role may be missing object permissions.

Fix:

```bash
mount | grep s3-mount
ls -l ~/s3-mount
aws s3 ls "s3://$BUCKET_NAME/"
```

### Cleanup does not remove the mount

Cause:

- `cleanup.sh` is being run on a different machine from the one where the mount exists.

Fix:

- Run the unmount step directly on the EC2 instance:

```bash
fusermount -u ~/s3-mount
```

If needed:

```bash
sudo umount ~/s3-mount
```

## Security Notes

- The bucket has public access blocked by default.
- The IAM policy is scoped to a single bucket rather than all buckets in the account.
- This repo is intended for learning and demos. For production, consider adding:
  - Naming conventions for multiple environments
  - Logging and monitoring
  - Stronger validation and error handling
  - Infrastructure as code with Terraform or CloudFormation
  - Persistent mount automation through systemd

## Limitations

- The region is hardcoded to `af-south-1` in `setup.sh`.
- `test.sh` currently performs a simple write check only.
- `cleanup.sh` assumes the demo resource names created by `setup.sh`.
- The scripts do not automatically launch or update the EC2 instance for you.

## Recommended Improvements

If you want to extend this project, good next steps would be:

- Add argument parsing instead of relying only on environment variables
- Allow overriding the AWS region
- Add a script to attach the instance profile automatically
- Expand `test.sh` to verify read, list, and delete operations
- Add idempotency checks to the setup and cleanup scripts
- Add systemd unit files for automatic mounting at boot

## Cleanup

When you are done, export the same bucket name and run:

```bash
export BUCKET_NAME=<your-bucket-name>
bash cleanup.sh
```

Also terminate the EC2 instance if it was created only for this demo.

## License

Add the license section that matches how you want to distribute this repository.
