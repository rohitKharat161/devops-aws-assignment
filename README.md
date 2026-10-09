\# AWS Infrastructure \& CI/CD Automation with Terraform



\## Project Overview



This project provisions AWS infrastructure using Terraform and validates infrastructure changes through GitHub Actions.



The infrastructure is designed to host a web application on private EC2 instances behind an Application Load Balancer, with a private MySQL RDS database and supporting AWS security and logging services.



\## Architecture



\* \*\*Amazon VPC:\*\* Isolated network using the `10.0.0.0/16` CIDR.

\* \*\*Public subnets:\*\* Host the Application Load Balancer and NAT Gateway across two Availability Zones.

\* \*\*Private application subnets:\*\* Host EC2 instances managed by an Auto Scaling Group.

\* \*\*Private database subnets:\*\* Host the MySQL RDS database.

\* \*\*Application Load Balancer:\*\* Routes HTTP requests to healthy application instances.

\* \*\*EC2 Auto Scaling Group:\*\* Maintains two application instances.

\* \*\*Amazon RDS:\*\* Private MySQL database with encryption and Multi-AZ configuration.

\* \*\*AWS Secrets Manager:\*\* Stores database credentials.

\* \*\*Amazon S3:\*\* Stores ALB access logs.

\* \*\*Terraform remote state:\*\* Stores Terraform state in a private, encrypted S3 bucket.

\* \*\*GitHub Actions:\*\* Runs Terraform initialization, formatting checks, validation, and planning.



\## Technology Stack



\* AWS

\* Terraform

\* Git and GitHub

\* GitHub Actions

\* Linux / Ubuntu

\* Nginx

\* Amazon EC2, VPC, ALB, Auto Scaling, RDS, S3, IAM, and Secrets Manager



\## Application Health Check



The application exposes a `/health` endpoint.



\*\*HTTP endpoint:\*\*



http://devops-assignment-alb-1867157216.ap-south-1.elb.amazonaws.com/health



Expected response:



`OK`



The endpoint can also be tested from a terminal:



```bash

curl -i http://devops-assignment-alb-1867157216.ap-south-1.elb.amazonaws.com/health

```



A successful health check returns HTTP `200`.



\## CI/CD Workflow



The GitHub Actions workflow runs on pushes to the `main` branch and pull requests targeting `main`.



The workflow performs:



1\. Repository checkout.

2\. Terraform setup.

3\. AWS authentication using GitHub OIDC.

4\. Terraform initialization.

5\. Terraform formatting check.

6\. Terraform validation.

7\. Terraform plan.



The current workflow validates and plans changes; it does not automatically apply infrastructure changes.



\## Security Measures



\* EC2 instances are placed in private application subnets.

\* RDS is not publicly accessible.

\* Security groups restrict application and database traffic.

\* Database credentials are stored in AWS Secrets Manager.

\* EC2 accesses the database secret through an IAM role.

\* S3 buckets have public access blocked and encryption enabled.

\* Terraform state is stored in a private S3 backend.

\* GitHub Actions authenticates through OIDC instead of storing long-lived AWS access keys in GitHub secrets.



\*\*Permission note:\*\* Review and restrict the GitHub Actions IAM role before production use. Its current `AdministratorAccess` policy is broader than least-privilege access requires.



\## Known Limitations



\* The Application Load Balancer currently has an HTTP listener. Public HTTPS requires a suitable ACM certificate, normally issued for a domain the user controls.

\* The current design uses one NAT Gateway, so outbound connectivity is not fully redundant across Availability Zones.

\* The deployment workflow does not automatically apply Terraform changes.



\## Repository Structure



```text

devops-aws-assignment/

├── .github/

│   └── workflows/

│       └── terraform.yml

├── terraform/

│   ├── backend.tf

│   ├── github-oidc.tf

│   └── \*.tf

└── README.md

```



\## Cleanup



AWS resources may incur charges. After testing or evaluation, review the infrastructure and destroy resources that are no longer required. Do not destroy resources while they are still needed for demonstration or evaluation.



