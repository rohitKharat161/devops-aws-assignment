# =========================
# RDS Subnet Group
# =========================

resource "aws_db_subnet_group" "mysql" {
  name = "${var.project_name}-mysql-subnet-group"

  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name    = "${var.project_name}-mysql-subnet-group"
    Project = var.project_name
  }
}

# =========================
# RDS MySQL Instance
# =========================

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "appdb"
  username = "admin"
  password = random_password.db.result

  port = 3306

  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  multi_az = true

  backup_retention_period = 1

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name    = "${var.project_name}-mysql"
    Project = var.project_name
  }
}