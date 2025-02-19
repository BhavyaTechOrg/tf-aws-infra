# tf-aws-infra

## Assignment 3
### AWS CLI Installation and Configuration (Windows)
1. Install AWS CLI
Download & Install:
AWS CLI Installer
Follow on-screen instructions.

Verify Installation:
Open Command Prompt or PowerShell and run : aws --version
1. Create IAM User & Group (Least Privilege)
In AWS IAM Console:

Create Group (e.g., LimitedAccessGroup)
Attach specific permissions instead of AdministratorAccess.

Create User:

Select Programmatic access.
Add user to the LimitedAccessGroup.
Download .csv file with Access Key ID & Secret.

3. Configure AWS CLI
Run in Command Prompt: aws configure --profile [your profile name]
Enter:

Access Key ID
Secret Access Key
Region (e.g., us-east-1)
Output format (json, text, table)
1. Test Setup
aws sts get-caller-identity --profile [your profile name]
If successful, it returns IAM user details.

1. Security Best Practices
Never use Admin access for CLI users.
Keep credentials secure (avoid hardcoding).
Use IAM roles when possible.