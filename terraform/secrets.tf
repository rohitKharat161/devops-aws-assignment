# =========================
# Database Credentials Secret
# =========================

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}/database-credentials"

  description = "Database credentials for the DevOps assignment"

  tags = {
    Name    = "${var.project_name}-db-secret"
    Project = var.project_name
  }
}

# =========================
# Random Database Password
# =========================

resource "random_password" "db" {
  length = 20

  special = true
}

# =========================
# Secret Value
# =========================

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
  })
}