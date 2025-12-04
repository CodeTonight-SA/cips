# /terraform-init Command

Bootstrap AWS infrastructure project with Terraform following 2025 best practices.

## Usage

```text
/terraform-init [project-name] [--region REGION]
```text

## What It Does

1. Creates standard Terraform project structure
2. Generates reusable module templates (VPC, RDS, ECS, etc.)
3. Sets up remote state management (S3 + DynamoDB)
4. Creates multi-environment configurations (prod/staging/dev)
5. Configures security (KMS, WAF, security groups)
6. Generates deployment scripts
7. Creates comprehensive documentation

## Example

```text
/terraform-init redr --region me-south-1
```text

Creates complete infrastructure repository following the SKILL.md protocols.
