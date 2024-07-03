resource "aws_key_pair" "access_key" {
  key_name   = "akalaj-min-key"
  public_key = var.sshkey # This key is provided via TF vars on the command line

  tags = {
    Name     = "ec2 key"
    CreateBy = "Terraform"
    Owner    = "Alexander Kalaj"
    Purpose  = "MinIO-Training"
  }
}

resource "aws_instance" "minio_host" {
  for_each = toset(var.hosts) # Creates a EC2 instance per string provided

  ami                         = "ami-03c983f9003cb9cd1" # us-west-2 AMI | Ubuntu 22.04.4 LTS (Jammy Jellyfish)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.access_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main_vpc_sg.id]
  subnet_id                   = aws_subnet.public.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Attach Profile To allow AWS CLI commands

  # MinIO EBS volume
  dynamic "ebs_block_device" {
    for_each = var.disks
    content {
      device_name           = "/dev/sd${ebs_block_device.value}"
      volume_size           = 5
      delete_on_termination = true
      volume_type           = "gp2"
    }
  }  

  # User data script to bootstrap MinIO
  user_data = base64encode(templatefile("setup.sh", {
        min-hostname        = "minio-${each.key}"
        disks               = join(" ", formatlist("xvd%s", var.disks))
  } ))

  tags = {
    Name     = "minio-${each.key}"
    CreateBy = "Terraform"
    Owner    = "Alexander Kalaj"
    Purpose  = "MinIO-Training"
  }
}


resource "aws_security_group" "main_vpc_sg" {
  name   = "minio-test-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Print IP Addresses
output "public_ip_address" {
  value = { for key, instance in aws_instance.minio_host : key => instance.public_ip }
}
