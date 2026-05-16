variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "multi-region-eks"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "multi-region-eks"
}

variable "state_bucket_name" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "aws-terraform-state-bucket-0011"
}

variable "regions" {
  description = "List of regions to deploy EKS clusters"
  type = list(object({
    region = string
    azs    = list(string)
  }))
  default = [
    {
      region = "us-west-2"
      azs    = ["us-west-2a", "us-west-2b", "us-west-2c"]
    },
    {
      region = "us-east-1"
      azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  ]
}

