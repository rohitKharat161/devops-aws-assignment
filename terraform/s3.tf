# =========================
# S3 Bucket for ALB Logs
# =========================

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-alb-logs"

  tags = {
    Name    = "${var.project_name}-alb-logs"
    Project = var.project_name
  }
}

# =========================
# Block Public Access
# =========================

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================
# Server-Side Encryption
# =========================

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =========================
# ALB Access Logs Bucket Policy
# =========================

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowALBGetBucketAcl"
        Effect = "Allow"

        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }

        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.alb_logs.arn
      },
      {
        Sid    = "AllowALBWriteLogs"
        Effect = "Allow"

        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

# =========================
# Enable ALB Access Logs
# =========================

resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
  }
}