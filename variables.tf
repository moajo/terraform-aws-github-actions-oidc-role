variable "role_name" {
  type        = string
  description = "The name of the role"
}

variable "github_actions_oidc_provider_arn" {
  type        = string
  default     = null
  description = <<EOT
ARN of aws_iam_openid_connect_provider
(default: 'arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com')
EOT
}

variable "repo_to_allow_assume" {
  type        = string
  description = <<EOT
GitHub repository to allow Assume for this role.
(e.g. 'moajo/hoge-repo')
EOT
}

variable "branches_to_allow_assume" {
  type        = list(string)
  default     = null
  description = <<EOT
Deny assuming from branches other than those included in this list.
If this value is null, assuming from all branches is allowed.
EOT
}

variable "permissions_boundary_arn" {
  type        = string
  default     = null
  description = <<EOT
ARN of the permissions boundary to use for this role.
EOT
}
