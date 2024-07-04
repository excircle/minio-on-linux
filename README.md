# Minio on Linux

This repository is dedicated to using and installing [MinIO](https://min.io/product/enterprisearchitecture) on Linux.

![MinIO Logo](https://blog.min.io/content/images/2019/05/0_hReq8dEVSFIYJMDv.png)

# Steps for Installation

Please note, these instructions are place holders and will be updated in the near future to be cleaner and easier to read. Instructions are written for installation on Macbook Pro

```bash
# 1.) Clone Directory

git clone https://github.com/excircle/minio-on-linux.git

# 2.) CD into 'terraform' directory and Initialize
cd minio-on-linux/terraform
terraform init

# 3.) Configure AWS Credentials
user@host ~: aws configure                            
AWS Access Key ID [********************]: 
AWS Secret Access Key [********************]: 
Default region name [us-west-2]: 
Default output format [json]:

# 4.) Load your public SSH key
export TF_VAR_sshkey=$(cat ~/.ssh/MY-KEY.pub)

# 5.) Configure number of hosts & disk - Default is 2 hosts, 4 disks
vim variables.tf

# 6.) Terraform apply
terraform apply

# 7.) Allow 5 minutes after apply for cloud-init process to complete - Start MinIO
ssh -i ~/.ssh/sre-key ubuntu@$(terraform state show 'aws_instance.minio_host["minio-1"]' | grep "public_ip\ " | awk '{print $NF}' | sed 's|"||g') "sudo systemctl start minio"
ssh -i ~/.ssh/sre-key ubuntu@$(terraform state show 'aws_instance.minio_host["minio-2"]' | grep "public_ip\ " | awk '{print $NF}' | sed 's|"||g') "sudo systemctl start minio"

# 8.) Visit public IP and login with credentials
echo -e "http://$(terraform state show 'aws_instance.minio_host["minio-1"]' | grep "public_ip\ " | awk '{print $NF}' | sed 's|"||g'):9001"
```