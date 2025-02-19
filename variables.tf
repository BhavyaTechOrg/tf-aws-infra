variable "aws_region" {
  type        = string
  default     = "us-west-1" # Modify as needed
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  default     = "dev"
  description = "AWS CLI profile for authentication"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment tag (e.g., dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "CIDR blocks for private subnets"
}

variable "name_prefix" {
  type        = string
  default     = "tf-assign3"
  description = "A prefix to uniquely identify resources"
}
