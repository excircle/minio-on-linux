# Download MinIO Server
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240510014138.0.0_amd64.deb -O minio.deb

# Install MinIO Server
sudo dpkg -i minio.deb

# Create a MinIO Service File
sudo cat << EOF > /usr/lib/systemd/system/minio.service
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use After=minio.server
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
EOF

# Create MinIO Group
sudo groupadd -r minio-user

# Create MinIO User
sudo useradd -M -r -g minio-user minio-user

# Create MinIO Data Directory
sudo mkdir -p /mnt/data

# Set MinIO Data Directory Permissions
sudo chown minio-user:minio-user /mnt/data

cat << EOF > /etc/default/minio
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment

MINIO_ROOT_USER=minadmin
MINIO_ROOT_PASSWORD=minpass

# MINIO_VOLUMES sets the storage volume or path to use for the MinIO server.

MINIO_VOLUMES="/mnt/data"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# For example, --console-address :9001 sets the MinIO Console listen port
MINIO_OPTS="--console-address ec2-54-218-96-88.us-west-2.compute.amazonaws.com:9001"

# MINIO_SERVER_URL sets the hostname of the local machine for use with the MinIO Server
# MinIO assumes your network control plane can correctly resolve this hostname to the local machine

# Uncomment the following line and replace the value with the correct hostname for the local machine and port for the MinIO server (9000 by default).

MINIO_SERVER_URL="http://ec2-54-218-96-88.us-west-2.compute.amazonaws.com:9000"
EOF