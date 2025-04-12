# ----------------------
# Fetch current AWS Account ID (needed for custom key policies)
# ----------------------
data "aws_caller_identity" "current" {}

# ----------------------
# KMS key for EC2 instance encryption
# ----------------------
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 instance encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "Allow account usage",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow EC2 usage",
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      },
      {
        Sid : "Allow service-linked role use of the customer managed key",
        Effect : "Allow",
        Principal : {
          AWS : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      },
      {
        Sid : "Allow attachment of persistent resources",
        Effect : "Allow",
        Principal : {
          AWS : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        Action : [
          "kms:CreateGrant"
        ],
        Resource : "*",
        Condition : {
          Bool : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })

  tags = {
    Name        = "ec2-kms-key-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/ec2-key-${random_id.resource_suffix.hex}"
  target_key_id = aws_kms_key.ec2_key.key_id
}

# ----------------------
# KMS key for RDS encryption
# ----------------------
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS database encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "Allow account usage",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow RDS usage",
        Effect : "Allow",
        Principal : {
          Service : "rds.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })

  tags = {
    Name        = "rds-kms-key-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-key-${random_id.resource_suffix.hex}"
  target_key_id = aws_kms_key.rds_key.key_id
}

# ----------------------
# KMS key for S3 bucket encryption
# ----------------------
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "Allow account usage",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow S3 usage",
        Effect : "Allow",
        Principal : {
          Service : "s3.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })

  tags = {
    Name        = "s3-kms-key-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-key-${random_id.resource_suffix.hex}"
  target_key_id = aws_kms_key.s3_key.key_id
}

# ----------------------
# KMS key for Secrets Manager encryption
# ----------------------
resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Sid : "Allow account usage",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "Allow Secrets Manager usage",
        Effect : "Allow",
        Principal : {
          Service : "secretsmanager.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })

  tags = {
    Name        = "secrets-kms-key-${random_id.resource_suffix.hex}"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/secrets-key-${random_id.resource_suffix.hex}"
  target_key_id = aws_kms_key.secrets_key.key_id
}
