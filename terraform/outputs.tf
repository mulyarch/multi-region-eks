output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions — add as GitHub Secret AWS_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

