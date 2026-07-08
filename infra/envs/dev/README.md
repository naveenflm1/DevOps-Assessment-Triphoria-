# Dev Terraform environment

This environment is intentionally small and uses local backend state for assessment review.

```bash
terraform init
terraform validate
terraform plan -refresh=false
```

For real AWS usage, replace the mock provider credentials and migrate backend state to S3 using `backend-s3.example.hcl`.
