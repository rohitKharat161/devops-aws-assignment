\# AWS Infrastructure \& CI/CD Automation with Terraform



\## Project Overview



This project provisions AWS infrastructure using Terraform and validates infrastructure changes through GitHub Actions.



The infrastructure hosts a web application on private EC2 instances behind an Application Load Balancer, with a private MySQL RDS database and supporting AWS security and logging services.



\## Architecture



flowchart TB

&#x20;   DEV\["Developer"] --> GH\["GitHub Repository"]

&#x20;   GH --> GA\["GitHub Actions"]

&#x20;   GA --> OIDC\["GitHub OIDC Authentication"]

&#x20;   OIDC --> IAM\["AWS IAM Role"]

&#x20;   IAM --> TF\["Terraform Init, Validate and Plan"]

&#x20;   TF --> STATE\[("S3 Remote State")]



&#x20;   USER\["Users"] --> IGW\["Internet Gateway"]



&#x20;   subgraph AWS\["AWS Region: ap-south-1"]

&#x20;       subgraph VPC\["VPC: 10.0.0.0/16"]

&#x20;           ALB\["Application Load Balancer"]



&#x20;           subgraph AZ1\["Availability Zone A"]

&#x20;               PUB1\["Public Subnet"]

&#x20;               NAT\["NAT Gateway"]

&#x20;               EC2A\["Private App Subnet<br/>EC2 Instance 1"]

&#x20;               DB1\["Private DB Subnet A"]

&#x20;           end



&#x20;           subgraph AZ2\["Availability Zone B"]

&#x20;               PUB2\["Public Subnet"]

&#x20;               EC2B\["Private App Subnet<br/>EC2 Instance 2"]

&#x20;               DB2\["Private DB Subnet B"]

&#x20;           end



&#x20;           ASG\["Auto Scaling Group"]

&#x20;           RDS\[("RDS MySQL Multi-AZ")]

&#x20;       end



&#x20;       SECRET\["AWS Secrets Manager"]

&#x20;       LOGS\[("S3 ALB Access Logs")]

&#x20;   end



&#x20;   IGW --> ALB

&#x20;   ALB --> EC2A

&#x20;   ALB --> EC2B

&#x20;   ASG -.-> EC2A

&#x20;   ASG -.-> EC2B

&#x20;   EC2A --> RDS

&#x20;   EC2B --> RDS

&#x20;   EC2A --> SECRET

&#x20;   EC2B --> SECRET

&#x20;   EC2A --> NAT

&#x20;   EC2B --> NAT

&#x20;   NAT --> IGW

&#x20;   DB1 -.-> RDS

&#x20;   DB2 -.-> RDS

&#x20;   ALB -.-> LOGS





\## Architecture Components



\* Amazon VPC with CIDR 10.0.0.0/16

\* Two public subnets across two Availability Zones

\* Two private application subnets

\* Two private database subnets

\* Internet Gateway and NAT Gateway

\* Application Load Balancer with HTTP listener

\* EC2 Auto Scaling Group with two instances

\* Private, encrypted, Multi-AZ Amazon RDS MySQL database

\* AWS Secrets Manager for database credentials

\* Amazon S3 for ALB access logs

\* Encrypted S3 remote backend for Terraform state

\* GitHub Actions with GitHub OIDC authentication



\## Technology Stack



\* AWS

\* Terraform

\* Git and GitHub

\* GitHub Actions

\* Linux and Ubuntu

\* Nginx

\* Amazon EC2, VPC, ALB, Auto Scaling, RDS, S3, IAM and Secrets Manager



\## Application Health Check



Health check endpoint:



http://devops-assignment-alb-1867157216.ap-south-1.elb.amazonaws.com/health



Expected response: OK



Test using:



curl -i http://devops-assignment-alb-1867157216.ap-south-1.elb.amazonaws.com/health





A successful health check returns HTTP 200.



\## CI/CD Workflow



The GitHub Actions workflow runs on pushes to the main branch and pull requests targeting main.



Workflow steps:



1\. Check out the repository.

2\. Set up Terraform.

3\. Authenticate to AWS using GitHub OIDC.

4\. Initialize Terraform.

5\. Check Terraform formatting.

6\. Validate the Terraform configuration.

7\. Generate a Terraform plan.



The workflow does not automatically apply infrastructure changes.



\## Security Measures



\* EC2 instances run in private application subnets.

\* RDS is not publicly accessible.

\* Security groups restrict application and database traffic.

\* Database credentials are stored in AWS Secrets Manager.

\* EC2 accesses the database secret through an IAM role.

\* S3 buckets block public access and use encryption.

\* Terraform state is stored in a private, encrypted S3 backend.

\* S3 state locking is enabled.

\* GitHub Actions uses OIDC instead of long-lived AWS access keys.

\* The GitHub Actions role uses ReadOnlyAccess and additional scoped permissions for Terraform state and the database secret.



ReadOnlyAccess is a broad read-only managed policy. Review permissions before production use.



\## Known Limitations



\* The ALB currently uses HTTP. HTTPS requires an ACM certificate and HTTPS listener configuration.

\* One NAT Gateway is used, so outbound connectivity is not fully redundant across Availability Zones.

\* GitHub Actions runs Terraform plan but does not automatically apply changes.

\* AWS resources may incur charges while deployed.



\## Repository Structure



devops-aws-assignment/

├── .github/

│   └── workflows/

│       └── terraform.yml

├── terraform/

│   ├── backend.tf

│   ├── github-oidc.tf

│   └── \*.tf

└── README.md



\## Cleanup



Review AWS resources after testing or evaluation. Destroy resources that are no longer required, and review the Terraform destroy plan before confirming. Do not delete resources needed for demonstration or evaluation.



\## Project Status



\* AWS infrastructure provisioned using Terraform.

\* ALB health check verified.

\* EC2 Auto Scaling Group configured with two instances.

\* RDS MySQL configured for Multi-AZ deployment.

\* Terraform remote state configured in S3.

\* GitHub OIDC authentication configured.

\* GitHub Actions workflow successfully executed.



