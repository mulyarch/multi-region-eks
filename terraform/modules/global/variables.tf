variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "region_endpoints" {
  description = "Map of region to NLB ARN for Global Accelerator endpoints"
  type = list(object({
    region          = string
    nlb_arn         = string
    health_check_port = number
  }))
}

