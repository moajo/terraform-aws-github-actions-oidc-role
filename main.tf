data "aws_caller_identity" "current" {}
locals {
  github_actions_oidc_provider_arn = var.github_actions_oidc_provider_arn != null ? var.github_actions_oidc_provider_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  allow_all                        = var.branches_to_allow_assume == null

  # NOTE: jsonencode() is required to avoid "The true and false result expressions must have consistent types."
  condition_block = local.allow_all ? jsonencode({
    "StringLike" : {
      "token.actions.githubusercontent.com:sub" : "repo:${var.repo_to_allow_assume}:*",
    },
    }) : jsonencode({
    "ForAnyValue:StringLike" : {
      "token.actions.githubusercontent.com:sub" : [
        for branch_pattern in var.branches_to_allow_assume : "repo:${var.repo_to_allow_assume}:ref:refs/heads/${branch_pattern}"
      ]
    }
  })
}
resource "aws_iam_role" "main" {
  name = var.role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : local.github_actions_oidc_provider_arn
        },
        "Condition" : jsondecode(local.condition_block),
      }
    ]
  })
}
