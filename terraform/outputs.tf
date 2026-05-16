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

