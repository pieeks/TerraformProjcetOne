output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS PostgreSQL instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Hostname of the RDS PostgreSQL instance"
  value       = aws_db_instance.main.address
}

output "ssh_command" {
  description = "Example SSH command to connect to the EC2 instance"
  value       = "ssh -i <path-to-private-key> ec2-user@${aws_instance.main.public_ip}"
}

output "psql_command" {
  description = "Example psql command to run on the EC2 instance"
  value       = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d testdb"
}
