# Create Server IP Variable
SERVER=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --filters "Name=instance-state-name,Values=running" --output text)

# Download MinIO Server Binary
wget https://dl.min.io/server/minio/release/linux-amd64/minio

# Make executable
chmod +x minio

# Move into /usr/local/bin
sudo mv minio /usr/local/bin/

# Create MinIO Data Directory
mkdir ~/minio

# Start MinIO Server
minio server ~/minio --console-address :9090 &

# Download MinIO Command Line Client
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# Make Executable
chmod +x mc

# Add to usr local
sudo mv mc /usr/local/bin

# Create Alias for your server
mc alias set 'myminio' 'http://${SERVER}:9000' 'minioadmin' 'minioadmin'

# Create minio-user group
sudo groupadd -r minio-user

# Create minio-user user
sudo useradd -m -d /home/minio-user -r -g minio-user minio-user

# Create minio-user home dir
sudo mkdir -p /home/minio-user/.minio/certs

# Create minio-user data dir
sudo mkdir /mnt/data

# Change ownership of minio-user home dir
sudo chown minio-user:minio-user /mnt/data

# Change ownership of minio-user home dir
sudo chown -R minio-user:minio-user /home/minio-user

# Create a MinIO Service File
sudo cat << EOF > /usr/lib/systemd/system/minio.service
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
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
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

# Create MinIO Defaults File
sudo cat << EOF > /etc/default/minio
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

MINIO_ROOT_USER=myminioadmin
MINIO_ROOT_PASSWORD=miniopass

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

MINIO_VOLUMES="/mnt/data"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# For example, `--console-address :9001` sets the MinIO Console listen port
MINIO_OPTS="--address 0.0.0.0:9000 --console-address 0.0.0.0:9001"

# MINIO_SERVER_URL sets the hostname of the local machine for use with the MinIO Server
# MinIO assumes your network control plane can correctly resolve this hostname to the local machine

# Uncomment the following line and replace the value with the correct hostname for the local machine and port for the MinIO server (9000 by default).

MINIO_SERVER_URL="${SERVER}:9000"
EOF