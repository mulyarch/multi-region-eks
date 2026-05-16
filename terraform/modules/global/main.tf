# ==============================================================================
# AWS GLOBAL ACCELERATOR
# ==============================================================================

resource "aws_globalaccelerator_accelerator" "this" {
  name            = "${var.project_name}-ga"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled = false
  }

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

resource "aws_globalaccelerator_endpoint_group" "regions" {
  count = length(var.region_endpoints)

  listener_arn                  = aws_globalaccelerator_listener.http.id
  endpoint_group_region         = var.region_endpoints[count.index].region
  health_check_port             = var.region_endpoints[count.index].health_check_port
  health_check_protocol         = "TCP"
  health_check_interval_seconds = 10
  threshold_count               = 2

  endpoint_configuration {
    endpoint_id                    = var.region_endpoints[count.index].nlb_arn
    weight                         = 100
    client_ip_preservation_enabled = false
  }
}

