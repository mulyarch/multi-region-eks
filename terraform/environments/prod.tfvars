project_name      = "multi-region-eks"
github_org        = "mulyarch"
github_repo       = "multi-region-eks"
state_bucket_name = "aws-terraform-state-bucket-0011"

regions = [
  {
    region = "us-west-2"
    azs    = ["us-west-2a", "us-west-2b", "us-west-2c"]
  },
  {
    region = "us-east-1"
    azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
]

nlb_arns = {}

