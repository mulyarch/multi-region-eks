# ==============================================================================
# REGION: us-west-2 (default provider)
# ==============================================================================

module "region_us_west_2" {
  source = "./modules/region-stack"

  project_name       = var.project_name
  region             = "us-west-2"
  azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_cidr           = "10.0.0.0/16"
  cluster_version    = "1.32"
  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 3

  providers = {
    aws = aws
  }
}

# ==============================================================================
# REGION: us-east-1
# ==============================================================================

module "region_us_east_1" {
  source = "./modules/region-stack"

  project_name       = var.project_name
  region             = "us-east-1"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr           = "10.1.0.0/16"
  cluster_version    = "1.32"
  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 1
  node_max_size      = 3

  providers = {
    aws = aws.us_east_1
  }
}

# ==============================================================================
# GLOBAL ACCELERATOR
# ==============================================================================
# NOTE: Global Accelerator is created after NLBs are deployed via Kubernetes.
# The NLBs are created by the LoadBalancer Service in EKS, not by Terraform.
# We'll handle this in a separate apply step after app deployment.
# ==============================================================================

