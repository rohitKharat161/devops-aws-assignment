resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name    = "${var.project_name}-github-oidc"
    Project = var.project_name
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:rohitKharat161@216740799/devops-aws-assignment@1410245714:ref:refs/heads/main"
          }
        }
      }
    ]

  })

  tags = {
    Name    = "${var.project_name}-github-actions"
    Project = var.project_name
  }
}

# Read-only permissions for Terraform plan.

resource "aws_iam_role_policy_attachment" "github_actions_readonly" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Limited access to Terraform remote state and its lock file.

resource "aws_iam_role_policy" "github_actions_state" {
  name = "${var.project_name}-github-actions-state"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListTerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::devops-assignment-tfstate-587806480204"
      },
      {
        Sid    = "AccessTerraformStateAndLockObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::devops-assignment-tfstate-587806480204/terraform.tfstate",
          "arn:aws:s3:::devops-assignment-tfstate-587806480204/terraform.tfstate.tflock"
        ]
      }
    ]

  })
}
