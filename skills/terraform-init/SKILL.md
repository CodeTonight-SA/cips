# Terraform Infrastructure Initialization Skill

**Slash Command**: `/terraform-init`

**Category**: Infrastructure as Code, DevOps

**Purpose**: Systematically bootstrap and configure AWS infrastructure using Terraform following best practices for 2025.

---

## When to Use

- Starting a new AWS infrastructure project
- Setting up multi-environment Terraform configurations (prod/staging/dev)
- Configuring remote state management with S3 + DynamoDB
- Creating reusable Terraform module libraries
- Establishing infrastructure patterns following AWS Well-Architected Framework

---

## Core Protocols

### 1. Project Structure Protocol

### Standard Terraform Repository Layout

```text
project-terraform/
├── environments/          # Environment-specific configs
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars.example
│   ├── staging/
│   └── development/
├── modules/              # Reusable modules
│   ├── vpc/
│   ├── ecs/
│   ├── rds/
│   └── [service]/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── lambda/               # Lambda function source
├── scripts/              # Deployment automation
│   ├── init-backend.sh
│   └── deploy.sh
├── docs/
│   ├── DEPLOYMENT.md
│   └── ARCHITECTURE.md
├── .gitignore
└── README.md
```text

### Naming Conventions
- Modules: `terraform-aws-<SERVICE>`
- Resources: `<project>-<environment>-<resource>`
- Files: `main.tf`, `variables.tf`, `outputs.tf` (standard names)

---

### 2. Remote State Management Protocol

**Best Practice**: Always use S3 backend with DynamoDB locking for production.

### Bootstrap Process

1. Create S3 bucket for state storage
2. Enable versioning + encryption
3. Create DynamoDB table for state locking
4. Generate backend.tf configuration
5. Run `terraform init` to migrate state

### S3 Bucket Configuration
- Versioning: Enabled (rollback capability)
- Encryption: AES256 or KMS
- Public Access: Blocked
- Lifecycle: Delete old versions after 90 days

### DynamoDB Table
- Primary Key: `LockID` (String)
- Billing Mode: PAY_PER_REQUEST
- Purpose: Prevent concurrent terraform operations

### Backend Configuration Template

```hcl
terraform {
  backend "s3" {
    bucket         = "project-terraform-state-env"
    key            = "terraform.tfstate"
    region         = "region"
    dynamodb_table = "project-terraform-locks-env"
    encrypt        = true
    profile        = "aws-profile"
  }
}
```text

---

### 3. Module Design Protocol

### SOLID Principles for Modules

- **Single Responsibility**: One module = one logical infrastructure component
- **Interface Segregation**: Expose only necessary outputs
- **Dependency Inversion**: Modules depend on abstracts (variables), not concretions

### Module Structure

```hcl
# main.tf - Resource definitions
# variables.tf - Input variables with types + descriptions
# outputs.tf - Exported values
# README.md - Auto-generated with terraform-docs (optional)
```text

### Variable Best Practices
- Always specify `type` and `description`
- Use `sensitive = true` for secrets
- Provide sensible defaults where appropriate
- Use validation blocks for constrained values

### Output Best Practices
- Export all values other modules might need
- Mark sensitive outputs as `sensitive = true`
- Provide clear descriptions

---

### 4. Multi-Environment Protocol

### Environment Separation Strategy

- **Shared Modules**: Same module code for all environments
- **Environment-Specific Values**: Different `terraform.tfvars` files
- **State Isolation**: Separate S3 backends per environment
- **Tagging**: Consistent environment tags for cost allocation

### Resource Sizing by Environment

| Resource | Production | Staging | Development |
|----------|-----------|---------|-------------|
| RDS | db.t3.medium, Multi-AZ | db.t3.small, Single-AZ | db.t3.micro |
| ECS Tasks | 3-10 (auto-scale) | 2-5 | 1-2 (fixed) |
| Redis | 3 nodes | 2 nodes | 1 node |
| NAT Gateways | 3 (per AZ) | 1 | 1 |

---

### 5. Security Protocol

### Encryption Requirements
- ✅ RDS: Encrypted at rest with KMS
- ✅ S3: Server-side encryption (KMS)
- ✅ Redis: At-rest + in-transit encryption
- ✅ Secrets Manager: KMS encryption
- ✅ EBS Volumes: KMS encryption

### IAM Best Practices
- Principle of least privilege
- Separate execution roles from task roles (ECS)
- Use managed policies where appropriate
- Enable MFA for production state access

### Network Security
- Private subnets for compute/data layers
- Security groups with minimal ingress rules
- WAF for public-facing load balancers
- VPC Flow Logs enabled

---

### 6. Cost Optimization Protocol

### Strategies

1. **Right-Sizing**: Match instance types to actual workload
2. **Reserved Instances**: For predictable, long-running resources (RDS)
3. **Savings Plans**: For Fargate compute
4. **S3 Lifecycle Policies**: Intelligent tiering for infrequent access
5. **Scheduled Scaling**: Scale down non-production during off-hours

### Cost Monitoring
- Tag all resources with `Environment`, `Project`, `ManagedBy`
- Enable AWS Cost Explorer tags
- Set up billing alerts via CloudWatch

---

### 7. Deployment Workflow Protocol

### Standard Deployment Process

```bash
# 1. Bootstrap backend (first time only)
./scripts/init-backend.sh production

# 2. Initialize Terraform
cd environments/production
terraform init

# 3. Plan changes
terraform plan -out=tfplan

# 4. Review plan
terraform show tfplan

# 5. Apply changes
terraform apply tfplan

# 6. Verify deployment
terraform output
aws ecs list-services --cluster example-production-cluster
```text

### CI/CD Integration
- Use `-backend-config` for dynamic backend configuration
- Store secrets in CI/CD platform secret store
- Require manual approval for production applies
- Run `terraform fmt -check` and `terraform validate` in PR checks

---

## AWS Provider Configuration

### Best Practices

```hcl
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"  # Pin major version
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```text

### Multi-Region Setup

```hcl
provider "aws" {
  alias  = "dr"
  region = "eu-west-1"
}

# Use alias for DR resources
resource "aws_s3_bucket" "dr_backup" {
  provider = aws.dr
  bucket   = "project-dr-backup"
}
```text

---

## Common Patterns

### Pattern 1: VPC with Multi-AZ

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project                  = "myproject"
  vpc_cidr                 = "10.0.0.0/16"
  availability_zone_count  = 3
  enable_nat_gateway       = true
  enable_flow_logs         = true

  tags = local.tags
}
```text

### Pattern 2: RDS with Automatic Backups

```hcl
module "rds" {
  source = "../../modules/rds"

  instance_class          = "db.t3.medium"
  multi_az                = true
  backup_retention_period = 30
  deletion_protection     = true

  kms_key_arn = module.security.rds_kms_key_arn
}
```text

### Pattern 3: ECS Fargate with Auto-Scaling

```hcl
module "ecs" {
  source = "../../modules/ecs"

  desired_count = 3
  min_capacity  = 3
  max_capacity  = 10

  # Secrets from Secrets Manager
  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "${aws_secretsmanager_secret.main.arn}:DATABASE_URL::"
    }
  ]
}
```text

---

## Quality Gates

### Pre-Deployment Checklist
- [ ] `terraform fmt -recursive` passed
- [ ] `terraform validate` passed
- [ ] `terraform plan` shows expected changes
- [ ] Secrets not hardcoded in `.tf` files
- [ ] `.tfvars` files in `.gitignore`
- [ ] Backend configuration correct for environment
- [ ] Default tags applied to all resources

### Post-Deployment Verification
- [ ] `terraform output` shows correct values
- [ ] Resources created in correct region/AZ
- [ ] Security groups have minimal ingress rules
- [ ] Encryption enabled on all data stores
- [ ] CloudWatch alarms configured
- [ ] Backups enabled for stateful resources

---

## Troubleshooting

### Common Issues

1. **State Lock Timeout**: Another terraform process running or crashed. Manually unlock: `terraform force-unlock LOCK_ID`

2. **Module Not Found**: Run `terraform init` to download modules

3. **Invalid Count Argument**: Conditional resources need `count` or `for_each`. Use `count = var.enable_feature ? 1 : 0`

4. **Cycle Dependency**: Refactor to break circular dependencies. Use `depends_on` sparingly.

5. **IAM Permission Denied**: Check AWS credentials and IAM policies for terraform user/role

---

## References

- [AWS Prescriptive Guidance - Terraform Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/)
- [Terraform Module Registry](https://registry.terraform.io/browse/modules)
- [terraform-docs](https://terraform-docs.io/) - Auto-generate module documentation

---

## Metrics

### Success Indicators
- Infrastructure provisioned in < 30 minutes
- Zero manual configuration required
- 100% resource tagging compliance
- All stateful resources have backups enabled
- Cost tracking per environment functional
