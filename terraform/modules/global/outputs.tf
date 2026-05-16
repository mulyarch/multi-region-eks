output "accelerator_dns_name" {
  description = "Global Accelerator DNS name"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "accelerator_ips" {
  description = "Global Accelerator static IPs"
  value       = aws_globalaccelerator_accelerator.this.ip_sets.ip_addresses
}

output "accelerator_arn" {
  description = "Global Accelerator ARN"
  value       = aws_globalaccelerator_accelerator.this.id
}

