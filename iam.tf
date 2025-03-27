# Random ID for unique resource names
resource "random_id" "resource_suffix" {
  byte_length = 4
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-${random_id.resource_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "EC2 Instance Role-${random_id.resource_suffix.hex}"
    Environment = "Production"
  }
}

# IAM Policy for S3 and Secrets Manager Access
resource "aws_iam_policy" "s3_secrets_policy" {
  name        = "S3AndSecretsManagerPolicy-${random_id.resource_suffix.hex}"
  description = "Allow EC2 to access S3 and Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
        Resource = [
          "${aws_s3_bucket.webapp_s3.arn}",
          "${aws_s3_bucket.webapp_s3.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource = "arn:aws:secretsmanager:us-east-1:888577018328:secret:db/credentials-*"
      }
    ]
  })

  tags = {
    Name        = "S3 and Secrets Manager Access-${random_id.resource_suffix.hex}"
    Environment = "Production"
  }
}

# Attach IAM Policies to IAM Role
resource "aws_iam_role_policy_attachment" "attach_s3_secrets_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_secrets_policy.arn
}

# Attach AWS managed CloudWatchAgentServerPolicy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${random_id.resource_suffix.hex}"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "EC2 Instance Profile-${random_id.resource_suffix.hex}"
    Environment = "Production"
  }
}