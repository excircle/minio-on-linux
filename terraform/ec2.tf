resource "aws_key_pair" "access_key" {
  key_name   = "akalaj-min-key"
  public_key = var.sshkey # This key is provided via variables

  tags = {
    Name     = "ec2 key"
    CreateBy = "Terraform"
    Owner    = "Alexander Kalaj"
    Purpose  = "MinIO-Training"
  }
}

resource "aws_instance" "minio_host" {
  ami                         = "ami-03c983f9003cb9cd1"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.access_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main_vpc_sg.id]
  subnet_id                   = aws_subnet.public.id

  tags = {
    Name     = "minio-host"
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
  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip_address" {
  value = aws_instance.minio_host.public_ip
}