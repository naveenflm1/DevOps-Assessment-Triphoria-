# Prod Terraform environment

This environment uses larger ECS and RDS sizing, longer RDS backup retention, Multi-AZ RDS, deletion protection, and final snapshots.

```bash
terraform init
terraform validate
terraform plan -refresh=false
```

For real AWS usage, replace the mock provider credentials and migrate backend state to S3 using `backend-s3.example.hcl`.
