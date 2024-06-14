# Assume Role
resource "aws_iam_role" "ec2_cli_role" {
  name = "ec2_cli_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      },
    ]
  })
}

# Grants policy holder auth to use AWS CLI
resource "aws_iam_policy" "describe_instances" {
  name        = "CLI-Policy"
  description = "Allow EC2 instances to run AWS CLI commands"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "ec2:DescribeInstances",
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

# Bind 'describe instances' policy to 'ec2_cli_role'
resource "aws_iam_role_policy_attachment" "ec2_describe_instances" {
  role       = aws_iam_role.ec2_cli_role.name
  policy_arn = aws_iam_policy.describe_instances.arn
}

# Bind 'ec2_cli_role' to 'ec2_instance_profile'
# Profile will be bound to EC2 during instance declaration
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_cli_role.name
}