# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for PostgreSQL RDS"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"] # Thats the default VPC ip range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres_rds" {
  identifier                  = "my-postgres-db"
  engine                      = "postgres"
  engine_version              = "14.7"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  storage_type                = "gp2"
  publicly_accessible         = false
  username                    = "adminofdb"
  manage_master_user_password = true # makes use of the secret manager for the master password
  db_name                     = "testdb"
  parameter_group_name        = "default.postgres14"
  multi_az                    = false
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
}

