# tf-aws-infra

# Cloud Native Web Application - Assignment 05

## Overview

This repository contains my implementation of Assignment 05 for the Cloud Computing course. I've automated the deployment of a cloud-native web application with RDS database integration and S3 file storage capabilities.

## Implementation Details

### Infrastructure as Code (Terraform)

I've implemented the following resources using Terraform:

- **VPC and Networking**: Reused my previous Terraform configuration for VPC, subnets, and route tables
- **S3 Bucket**: 
  - Created a private bucket with UUID-based name
  - Enabled default encryption
  - Configured lifecycle policy for STANDARD to STANDARD_IA transition after 30 days
  - Added bucket policy for secure access

- **IAM Roles**:
  - Created EC2 instance profile with S3 access permissions
  - Implemented least privilege principle with specific policies

- **Security Groups**:
  - Application security group for web traffic
  - Database security group allowing traffic only from application security group

- **RDS Configuration**:
  - Custom parameter group for MySQL 8.0
  - DB instance in private subnet with appropriate specifications
  - Secured with proper credentials and no public access

### AMI Updates (Packer)

Modified my Packer template to:
- Remove local database installation
- Configure SystemD service for auto-start
- Create dedicated non-privileged application user
- Set proper file permissions

### Web Application Updates

Updated my web application to:
- Read database configuration from user data
- Connect to RDS instance for data persistence
- Implement file upload/retrieval APIs using S3
- Store file metadata in RDS
- Handle proper error responses and edge cases

## How to Deploy

1. Build the AMI using Packer:
   ```
   cd packer
   packer build ami.json
   ```

2. Deploy infrastructure using Terraform:
   ```
   cd terraform
   terraform init
   terraform apply
   ```

3. The application will automatically start on EC2 instance launch

## Testing the Application

I've tested the following functionality:
- Health check endpoint returns 200 OK
- File upload to S3 with proper metadata storage
- File metadata retrieval
- File deletion from both S3 and database
- Application auto-start after EC2 reboot

## Assignment 4

### Custom Machine Images & CI/CD with Packer, Terraform, and Cloud Integration

## Objective:

* Build custom application images (with a local DB installation) using Ubuntu 24.04 LTS.
* Automate image builds via Packer and integrate CI/CD with GitHub Actions.

### Key Requirements:

### Custom Image Creation:

* Use Ubuntu 24.04 LTS as the source image.
* Include all necessary application dependencies (e.g., Java/Tomcat or Python libraries) and a local database (MySQL/MariaDB/PostgreSQL).
* Ensure that the custom images remain private and are built within your DEV AWS account and DEV GCP Project.
* Build images within your default VPC.

### GitHub Actions Workflows:

* PR Triggers: Run packer fmt and packer validate on pull requests to enforce proper formatting and configuration, blocking merges if issues are detected.
* Post-Merge Workflow: Trigger a workflow to build custom images in AWS and GCP in parallel (artifact is built on the Actions runner and then copied into the image).
* Configure systemd to auto-start your application on instance launch, ensuring that application artifacts and configuration files are correctly owned by the non-login user/group csye6225.

### Terraform & Infrastructure:

* Update Terraform templates to create an EC2 security group allowing ingress on ports 22, 80, 443, and the port on which your application runs.
* Launch an EC2 instance using your custom AMI in a non-default VPC, with EBS volumes set to terminate upon instance termination.

### GCP

* Launch a Compute Engine instance from the custom machine image (ensuring that API endpoints are accessible and database connectivity can be verified).

### Commands to Run in your local machine

* Make sure to pass the env before you run 
* Replace your postgress username, password and ami_id

* $env:PKR_VAR_POSTGRES_USER="yourusername"
* $env:PKR_VAR_POSTGRES_PASSWORD="password"
* $env:PKR_VAR_ami_id="ami-ID"

* packer fmt -check packer
* packer init packer
* packer validate packer
  
### Commands to Run in your local machine once the AMI is built succesfully

* Note: Make sure you replace the AMI_ID 

* terraform init
* terraform fmt
* terraform validate
* terraform plan -var="aws_profile=dev" or 
* terraform apply -var-file="dev.tfvars" -auto-approve
* terraform destroy -var-file="dev.tfvars" -auto-approve


## Assignment 3

### AWS CLI Installation and Configuration (Windows)
1. Install AWS CLI
Download & Install: AWS CLI Installer

## Verify Installation:
Open Command Prompt or PowerShell and run : aws --version
1. Create IAM User & Group (Least Privilege)
In AWS IAM Console:

* Create Group (e.g., LimitedAccessGroup)
* Attach specific permissions instead of AdministratorAccess.

Create User:
* Select Programmatic access.
* Add user to the LimitedAccessGroup.
* Download .csv file with Access Key ID & Secret.

3. Configure AWS CLI
* Run in Command Prompt: aws configure --profile [your profile name]
Enter:
* Access Key ID
* Secret Access Key
* Region (e.g., us-east-1)
* Output format (json, text, table)

1. Test Setup
* aws sts get-caller-identity --profile [your profile name]
If successful, it returns IAM user details.

2. Security Best Practices
* Never use Admin access for CLI users.
* Keep credentials secure (avoid hardcoding).
* Use IAM roles when possible.


### Terraform CI/CD Setup

This repository automates AWS networking infrastructure setup using Terraform and enforces CI/CD via GitHub Actions

## Setup Instructions
1. Pre-requisites
Terraform v1.10.5+
AWS CLI (Configured with dev and demo profiles)
GitHub CLI (Optional)

## 2. Clone, Initialize, Deploy and Destroy Infrastructure
* terraform init
* terraform plan -var-file="dev.tfvars"
* tterraform apply -var-file="dev.tfvars"
* terraform destroy -var-file="dev.tfvars"

## CI/CD Workflow

The GitHub Actions pipeline runs on pull requests to main and performs:
* Terraform Format Check (terraform fmt)
* Terraform Validation (terraform validate)
* Blocks merging if validation fails
* Uploads logs on failure

## Troubleshooting
CI failures? Check logs in GitHub Actions
Terraform issues? Run locally

* terraform fmt -recursive
* terraform validate
