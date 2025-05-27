
# 🚀 Ghost CMS Deployment to AWS (Free Tier) with CI/CD, IaC & SAST

This project deploys [Ghost CMS](https://ghost.org/) on AWS using **Terraform** (under `infra/`) and sets up a **CI/CD pipeline** with GitHub Actions, GitLab CI, and Jenkins. It also includes **Semgrep** for Terraform SAST scanning with **Slack notifications**.

The code architecture and documentation created by **Eng. Kheir el dine Baaarini** 

The Credentials used in this code for deployement are limited for a specific user with **specific permissions**

---

## 🧱 Project Structure

```
.
├── .github/workflows/
│   ├── deploy.yml          # GitHub Actions pipeline for Terraform
│   └── semgrep.yml         # GitHub Actions for Semgrep SAST
├── infra/                  # Terraform code lives here
│   ├── main.tf             # EC2 instance & Security Group
│   ├── provider.tf         # AWS provider config
│   ├── user-data.sh        # EC2 instance bootstrap script
│   └── variables.tf        # Terraform variables
├── .gitlab-ci.yml          # GitLab CI config,  For running Terraform and Semgrep in GitLab CI and this file is added as extra info.
├── Jenkinsfile             # Jenkins pipelin, For running Terraform and Semgrep using Jenkins and this file is added as extra info.
├── .semgrep.yml            # Semgrep rule definition
└── README.md               # This file which is used as a documentation
```

---

## ⚙️ Technologies Used

- **Ghost CMS** (Docker)
- **Terraform** (IaC)
- **AWS EC2** (Free tier)
- **GitHub Actions**, **GitLab CI**, **Jenkins** (CI/CD)
- **Semgrep** (SAST)
- **Slack Webhook** for notifications

---

## 🌐 Deployment on AWS

### Terraform Setup

**infra/main.tf**
- Deploys a t2.micro EC2 instance with Ghost Docker container (port 2368).
- Creates a Security Group with open port `2368`.

**infra/provider.tf**
```hcl
provider "aws" {
  region = "us-east-1"
}
```

**infra/variables.tf**
```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}
```

**infra/user-data.sh**
```bash
#!/bin/bash
apt update -y
apt install -y docker.io
docker run -d --name ghost -p 2368:2368 ghost:latest
```

---

## 🚀 GitHub Actions CI/CD (`.github/workflows/deploy.yml`)

This workflow:

1. Sets up AWS credentials using GitHub secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
2. Runs Terraform Init, Format, Validate, and Plan

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1
```

---

## 🛡️ Semgrep SAST (`.github/workflows/semgrep.yml`)

Scans Terraform files using Semgrep and sends Slack notifications.

```yaml
- name: Run Semgrep
  uses: returntocorp/semgrep-action@v1
  with:
    config: "p/terraform"
    publishToken: ${{ secrets.SEMGREP_APP_TOKEN }}
```

Slack webhook:
```yaml
- name: Send Slack Notification
  run: |
    curl -X POST -H 'Content-type: application/json'     --data '{"text":"🔒 Semgrep SAST scan completed. Review results in GitHub Actions."}'     ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## 🧪 .gitlab-ci.yml

```yaml
validate_terraform:
  stage: validate
  image: hashicorp/terraform:light
  script:
    - cd infra
    - terraform init
    - terraform validate
    - terraform fmt -check

semgrep_scan:
  stage: semgrep
  image: returntocorp/semgrep
  script:
    - semgrep scan --config p/terraform
```

---

## ⚙️ Jenkinsfile

```groovy
pipeline {
    agent any
    stages {
        stage('Terraform Init & Validate') {
            steps {
                dir('infra') {
                    sh 'terraform init'
                    sh 'terraform fmt -check'
                    sh 'terraform validate'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh 'terraform plan'
                }
            }
        }
        stage('Semgrep Scan') {
            steps {
                sh 'docker run --rm -v $PWD:/src returntocorp/semgrep semgrep scan --config p/terraform'
            }
        }
    }
}
```

---

## 🔑 AWS Credentials Setup for GitHub Actions

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Create an IAM user with:
   - Programmatic access
   - `AmazonEC2FullAccess`, `AmazonVPCFullAccess`
3. Generate and save `Access Key ID` and `Secret Access Key`
4. Add them to GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
Note that in this repo they are saved as secrets and when we do the fork these secrets must be added
---

## 🛡️ Semgrep Rule (.semgrep.yml)

```yaml
rules:
  - id: aws-instance-public-ip
    patterns:
      - pattern: aws_instance
    message: "Avoid exposing public IPs unless necessary."
    severity: WARNING
```

---

## 📦 Requirements

- AWS account (Free Tier)
- IAM User with correct permissions
- GitHub repository with secrets configured
- Optional: Jenkins / GitLab CI

---

## 🧼 Cleanup

When done, destroy resources to avoid charges:

```bash
cd infra
terraform destroy
```

---

## 👤 Author

Eng. Kheir el dine Baarini
