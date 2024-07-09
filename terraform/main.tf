// build minio cluster using local module "minio-cluster"

module "minio-cluster" {
  source = "./module/minio-cluster"

  ec2_instance_type = "t2.micro"
  ec2_ami_image = "ami-03c983f9003cb9cd1"
  hosts = 2                     # Number of nodes with MinIO installed
  disks = ["h", "i", "j", "k"]  # Creates disks [sdh, sdi, sdj, sdk]
  sshkey = var.sshkey           # Use env variables | export TF_VAR_sshkey=$(cat ~/.ssh/your-key-name.pub)
  ec2_key_name = "minio-key"
}