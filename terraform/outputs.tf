
output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

# us-west-2 outputs
output "us_west_2_cluster_name" {
  description = "EKS cluster name in us-west-2"
  value       = module.region_us_west_2.cluster_name
}

output "us_west_2_ecr_url" {
  description = "ECR repository URL in us-west-2"
  value       = module.region_us_west_2.ecr_repository_url
}

# us-east-1 outputs
output "us_east_1_cluster_name" {
  description = "EKS cluster name in us-east-1"
  value       = module.region_us_east_1.cluster_name
}

output "us_east_1_ecr_url" {
  description = "ECR repository URL in us-east-1"
  value       = module.region_us_east_1.ecr_repository_url
}

output "eu_west_1_cluster_name" {
  value = module.region_eu_west_1.cluster_name
}

output "eu_west_1_ecr_url" {
  value = module.region_eu_west_1.ecr_repository_url
}


# Global Accelerator outputs
output "global_accelerator_dns" {
  description = "Global Accelerator DNS name — this is your single entry point"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "global_accelerator_ips" {
  description = "Global Accelerator static anycast IPs"
  value       = aws_globalaccelerator_accelerator.this.ip_sets[0].ip_addresses
}


