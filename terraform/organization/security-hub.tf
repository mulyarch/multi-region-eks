# ==============================================================================
# SECURITY HUB — Centralized Security Posture
# Aggregates findings from GuardDuty, Config, Inspector, etc.
# ==============================================================================

resource "aws_securityhub_account" "main" {}

# Enable CIS AWS Foundations Benchmark v3.0.0
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:us-west-2::standards/cis-aws-foundations-benchmark/v/3.0.0"

  depends_on = [aws_securityhub_account.main]
}

# Enable AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:us-west-2::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.main]
}

# Enable NIST 800-53 (relevant for defense/government)
resource "aws_securityhub_standards_subscription" "nist" {
  standards_arn = "arn:aws:securityhub:us-west-2::standards/nist-800-53/v/5.0.0"

  depends_on = [aws_securityhub_account.main]
}
