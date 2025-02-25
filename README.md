# tf-aws-infra





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
