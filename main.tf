resource "aws_iam_role" "main" {
  name = var.role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.github_actions.arn
        },
        "Condition" : {
          "StringLike" : {
            "vstoken.actions.githubusercontent.com:sub" : "repo:${var.repository}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://vstoken.actions.githubusercontent.com"
  client_id_list  = ["https://github.com/${var.repository}"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}
