##############################
# outputs.tf - Terraform outputs for Books API
##############################

#---------------------------------------
# Public IP address of the EC2 instance
#---------------------------------------
output "instance_public_ip" {
  description = "Public IP of the EC2 instance for HTTP access or SSH"
  value       = aws_instance.books_api_server.public_ip
}

#---------------------------------------
# Public DNS name of the EC2 instance
#---------------------------------------
output "instance_public_dns" {
  description = "Public DNS of the EC2 instance for HTTP access or SSH"
  value       = aws_instance.books_api_server.public_dns
}

#---------------------------------------
# CloudWatch Log Group name
#---------------------------------------
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group where application logs are stored"
  value       = aws_cloudwatch_log_group.app.name
}

