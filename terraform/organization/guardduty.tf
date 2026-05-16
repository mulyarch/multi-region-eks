# ==============================================================================
# GUARDDUTY — Threat Detection
# Monitors for malicious activity and unauthorized behavior
# ==============================================================================

resource "aws_guardduty_detector" "us_west_2" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Project  = var.project_name
    Security = "threat-detection"
    Region   = "us-west-2"
  }
}

resource "aws_guardduty_detector" "us_east_1" {
  provider = aws.us_east_1
  enable   = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Project  = var.project_name
    Security = "threat-detection"
    Region   = "us-east-1"
  }
}

resource "aws_guardduty_detector" "eu_west_1" {
  provider = aws.eu_west_1
  enable   = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = {
    Project  = var.project_name
    Security = "threat-detection"
    Region   = "eu-west-1"
  }
}

# SNS Topic for GuardDuty alerts
resource "aws_sns_topic" "guardduty_alerts" {
  name              = "${var.project_name}-guardduty-alerts"
  kms_master_key_id = aws_kms_key.security.id

  tags = {
    Project  = var.project_name
    Security = "alerting"
  }
}

# CloudWatch Event Rule to capture HIGH/CRITICAL findings
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.project_name}-guardduty-high-findings"
  description = "Capture GuardDuty HIGH and CRITICAL severity findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })

  tags = {
    Project  = var.project_name
    Security = "alerting"
  }
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "guardduty-to-sns"
  arn       = aws_sns_topic.guardduty_alerts.arn
}

resource "aws_sns_topic_policy" "guardduty_alerts" {
  arn = aws_sns_topic.guardduty_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.guardduty_alerts.arn
    }]
  })
}

