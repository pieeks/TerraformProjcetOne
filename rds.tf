data "aws_rds_engine_version" "postgresql" {
  engine             = "postgres"
  preferred_versions = ["16.14", "16.13", "16.12", "16.11", "16.10", "16.9"]
}

resource "aws_db_subnet_group" "main" {
  name       = "mein-cachyos-test-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "MeinCachyOSTestDBSubnetGroup"
  }
}

resource "aws_security_group" "rds" {
  name        = "mein-cachyos-test-rds-sg"
  description = "Security group for test RDS PostgreSQL instance"
  vpc_id      = aws_vpc.test_netzwerk.id

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  tags = {
    Name = "MeinCachyOSTestRDSSG"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "mein-cachyos-test-postgres"
  engine                 = data.aws_rds_engine_version.postgresql.engine
  engine_version         = data.aws_rds_engine_version.postgresql.version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  db_name                = "testdb"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  tags = {
    Name = "MeinCachyOSTestRDS"
  }
}
