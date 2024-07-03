#!/bin/bash

# Create Install AWS CLI
sudo apt update
sudo apt install awscli tree jq -y 

# Obtain Server IP
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
SERVER=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION  --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

# Setup Hostname
sudo hostnamectl set-hostname ${min-hostname}

# Establish Disks
for disk in ${disks}; do
  sudo mkfs.xfs /dev/$disk
  sudo mkdir -p /mnt/data/$disk
  sudo mount /dev/$disk /mnt/data/$disk
  echo "/dev/$disk /mnt/data/$disk xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
done
