# Minio on Linux

This repository is dedicated to using and installing [MinIO](https://min.io/product/enterprisearchitecture) on Linux. This project is for personal learning and education.

![MinIO Logo](https://blog.min.io/content/images/2019/05/0_hReq8dEVSFIYJMDv.png)

# Contents

The branches of this repository feature Terraform projects which implements MinIO on different versions of Linux. Currently, the Terraform projects provision a [Single Node Single Drive (SNSD)](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html) configuration to allow for quick experimentation.

| Branch | Description|
| - | - |
| [`main`](https://github.com/excircle/minio-on-linux/tree/main) | Defaults to MinIO on Ubuntu-based EC2 instance (Ubuntu 22.04.4 LTS <i>Jammy Jellyfish</i>) |
| [`ubuntu`](https://github.com/excircle/minio-on-linux/tree/ubuntu) | Identical to main branch |
| [`ubuntu-cluster`](https://github.com/excircle/minio-on-linux/tree/ubuntu-cluster) | MinIO on Ubuntu-based EC2 cluster (Ubuntu 22.04.4 LTS <i>Jammy Jellyfish</i>) |
| [`debian`](https://github.com/excircle/minio-on-linux/tree/debian) | MinIO on Debian-based EC2 instance (Debian 12 <i>Bookworm</i>) |

# Overview

The Terraform projects contained in this repo leverage AWS for infrastructure and AWS' `cloud-init` feature to bootstrap MinIO.

#### AWS Resources

- AWS VPC (`us-west-2`)
- AWS IGW (Internet Gateway)
- AWS Subnet (Public)
- AWS Route Table
- AWS IAM Policy
- AWS Assume Role
- AWS Instance Profile
- AWS EC2 Instance
- AWS SSH Key Pair
- AWS Security Group

#### Linux Resources (via [setup.sh]())

- `aws` CLI tool
- 5GB XFS mount (`/mnt/data`)
- `minio-user` Linux user
- `minio-user` Linux group

#### MinIO Resources (via [setup.sh]())

- `minio` binary
- `mc` binary
- `/etc/default/minio` config file
- `minio.service` SystemD file

# Installation & Usage

The following steps outline a high-level basic usage - ideal for running on a local laptop.

#### NOTE: These instructions assume you have [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed & [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured

| Steps | Commands |
| - | - |
| Clone Repo Locally | `git clone https://github.com/excircle/minio-on-linux.git` |
| Change Into `terraform` Directory | `cd minio-on-linux/terraform` |
| Initialize Terraform | `terraform init` |
| Provide Public SSH Key | `export TF_VAR_sshkey=$(cat ~/.ssh/your_public_key.pub)` |
| Create Terraform Execution Plan | `terraform plan -out tfplan` |
| Execute Plan | `terraform apply tfplan` |
| SSH To Host | `ssh -i ~/.ssh/your_public_key ubuntu@34.222.0.0` |
| Start MinIO | `sudo systemctl start minio` |
