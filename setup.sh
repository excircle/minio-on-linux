# Download MinIO Server Binary
wget https://dl.min.io/server/minio/release/linux-amd64/minio

# Make executable
chmod +x minio

# Move into /usr/local/bin
sudo mv minio /usr/local/bin/

# Create MinIO Data Directory
mkdir ~/minio

# Start MinIO Server
minio server ~/minio --console-address :9090

# Download MinIO Command Line Client
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# Make Executable
chmod +x mc

# Add to usr local
mv mc /usr/local/bin