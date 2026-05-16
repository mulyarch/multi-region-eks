# ==============================================================================
# GLOBAL ACCELERATOR
# ==============================================================================
# This is applied AFTER the first deployment, once NLBs exist.
# NLB ARNs are passed in as variables.
# ==============================================================================

variable "nlb_arns" {
  description = "Map of region to NLB ARN"
  type        = map(string)
  default     = {}
}

resource "aws_globalaccelerator_accelerator" "this" {
  name            = "${var.project_name}-ga"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    Project = var.project_name
  }
}

resource "aws_globalaccelerator_listener" "http" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "us_west_2" {
  count = lookup(var.nlb_arns, "us-west-2", "") != "" ? 1 : 0

  listener_arn                  = aws_globalaccelerator_listener.http.id
  endpoint_group_region         = "us-west-2"
  health_check_port             = 80
  health_check_protocol         = "TCP"
  health_check_interval_seconds = 10
  threshold_count               = 2

  endpoint_configuration {
    endpoint_id                    = var.nlb_arns["us-west-2"]
    weight                         = 100
    client_ip_preservation_enabled = false
  }
}

resource "aws_globalaccelerator_endpoint_group" "us_east_1" {
  count = lookup(var.nlb_arns, "us-east-1", "") != "" ? 1 : 0

  listener_arn                  = aws_globalaccelerator_listener.http.id
  endpoint_group_region         = "us-east-1"
  health_check_port             = 80
  health_check_protocol         = "TCP"
  health_check_interval_seconds = 10
  threshold_count               = 2

  endpoint_configuration {
    endpoint_id                    = var.nlb_arns["us-east-1"]
    weight                         = 100
    client_ip_preservation_enabled = false
  }
}

