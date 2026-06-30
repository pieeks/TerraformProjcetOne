variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access to EC2 (ideally your own IP as /32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "Public SSH key content for EC2 access"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "mein-cachyos-test-key"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Master username for RDS PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}
