# ----------------------
# Random ID for Unique Resource Names
# ----------------------
resource "random_id" "resource_suffix" {
  byte_length = 4
}

# ----------------------
# IAM Role for EC2 Instance
# ----------------------
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role-${random_id.resource_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "EC2 Instance Role-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

# ----------------------
# IAM Policy for S3 and Secrets Manager Access
# ----------------------
resource "aws_iam_policy" "s3_secrets_policy" {
  name        = "S3AndSecretsManagerPolicy-${random_id.resource_suffix.hex}"
  description = "Allow EC2 to access S3 and Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
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
        Resource = "arn:aws:secretsmanager:us-east-1:888577018328:secret:db/credentials-lf6QwA"

      }
    ]
  })

  tags = {
    Name        = "S3 and Secrets Manager Access-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

# ----------------------
# Attach IAM Policies to IAM Role
# ----------------------
resource "aws_iam_role_policy_attachment" "attach_s3_secrets_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ----------------------
# IAM Instance Profile for EC2
# ----------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile-${random_id.resource_suffix.hex}"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "EC2 Instance Profile-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}


# Allow EC2 to access all four KMS keys
resource "aws_iam_policy" "kms_policy" {
  name        = "KMSAccessPolicy-${random_id.resource_suffix.hex}"
  description = "Allow EC2 to use KMS keys for encryption/decryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
          "kms:CreateKey",
          "kms:TagResource",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
          "kms:DescribeKey",
          "kms:PutKeyPolicy"

        ],
        Resource = [
          aws_kms_key.ec2_key.arn,
          aws_kms_key.rds_key.arn,
          aws_kms_key.s3_key.arn,
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })

  tags = {
    Name        = "KMS Key Access-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

# Attach KMS policy to EC2 role
resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}
