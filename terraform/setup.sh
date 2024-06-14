#!/bin/bash

# Create Install AWS CLI
sudo apt update
sudo apt install awscli tree jq -y 

# Obtain Server IP
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
SERVER=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

# Create MinIO XFS Mount
sudo mkfs.xfs /dev/xvdh
sudo mkdir -p /mnt/data
sudo mount /dev/xvdh /mnt/data
echo "/dev/xvdh /mnt/data xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Download MinIO Server Binary
wget https://dl.min.io/server/minio/release/linux-amd64/minio

# Make executable
chmod +x minio

# Move into /usr/local/bin
sudo mv minio /usr/local/bin/

# Download MinIO Command Line Client
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# Make Executable
chmod +x mc

# Add to usr local
sudo mv mc /usr/local/bin

# Create minio-user group
sudo groupadd -r minio-user

# Create minio-user user
sudo useradd -m -d /home/minio-user -r -g minio-user minio-user

# Create minio-user home dir
sudo mkdir -p /home/minio-user/.minio/certs

# Create minio-user data dir
sudo mkdir /mnt/data

# Change ownership of minio-user home dir
sudo chown -R minio-user:minio-user /mnt/data

# Create MinIO Defaults File
sudo tee /etc/default/minio > /dev/null << EOF
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

MINIO_ROOT_USER=myminioadmin
MINIO_ROOT_PASSWORD=miniopass

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

MINIO_VOLUMES="/mnt/data"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# For example, '--console-address :9001' sets the MinIO Console listen port
MINIO_OPTS="--address 0.0.0.0:9000 --console-address 0.0.0.0:9001"

# MINIO_SERVER_URL sets the hostname of the local machine for use with the MinIO Server
# MinIO assumes your network control plane can correctly resolve this hostname to the local machine

# Uncomment the following line and replace the value with the correct hostname for the local machine and port for the MinIO server (9000 by default).

MINIO_SERVER_URL="http://${SERVER}:9000"
EOF

# Source defaults file
source /etc/default/minio

# Create a MinIO Service File
sudo tee /usr/lib/systemd/system/minio.service > /dev/null << 'EOF'
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio
AssertFileNotEmpty=/etc/default/minio

[Service]
Type=notify

WorkingDirectory=/usr/local/

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo 'Variable MINIO_VOLUMES not set in /etc/default/minio'; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=1048576

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutSec=infinity

SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
EOF