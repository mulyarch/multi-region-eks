terraform {
  backend "s3" {
    bucket       = "aws-terraform-state-bucket-0011"
    key          = "multi-region-eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

