provider "aws" {
  region = var.aws_region

  # Mock credentials let reviewers run `terraform plan -refresh=false`
  # without requiring an AWS account. Replace these for real deployments.
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
