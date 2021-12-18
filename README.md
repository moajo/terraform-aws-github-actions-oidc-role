# terraform-aws-github-actions-oidc-role

This is terraform module to create an iam role that can be assumeRole from github actions of a specific repository(and specific branches).

see: https://docs.github.com/ja/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

# usage

```tf
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

module "federation_role" {
  source                   = "git@github.com:moajo/terraform-aws-github-actions-oidc-role.git?ref=v2.0.0"
  role_name                = "hoge"
  repo_to_allow_assume     = "moajo/hogehoge"

  # Optional: Allow assume from all branches and tags by default.
  # branches_to_allow_assume = [
  #   "hoge",   # exact match
  #   "fuga-*", # pattern match(this matches "fuga-1" or "fuga-2"...)
  # ]
}

resource "aws_iam_role_policy" "sample" {
  name = "sample"
  role = module.federation_role.role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sts:GetCallerIdentity"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}
```

`.github/workflow/sample.yml`

```yml
name: get-caller-identity
on:
  push:

env:
  AWS_REGION: us-east-1
  AWS_ROLE_ARN: arn:aws:iam::xxxxxxxxxxxx:role/hoge

jobs:
  get-caller-identity:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ env.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      - run: aws sts get-caller-identity
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 3.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 3.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                     | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name                                                                                                                              | Description                                                                                                                          | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------- | ------- | :------: |
| <a name="input_branches_to_allow_assume"></a> [branches_to_allow_assume](#input_branches_to_allow_assume)                         | Deny assuming from branches other than those included in this list.<br>If this value is null, assuming from all branches is allowed. | `list(string)` | `null`  |    no    |
| <a name="input_github_actions_oidc_provider_arn"></a> [github_actions_oidc_provider_arn](#input_github_actions_oidc_provider_arn) | ARN of aws_iam_openid_connect_provider<br>(default: 'arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com')     | `string`       | `null`  |    no    |
| <a name="input_repo_to_allow_assume"></a> [repo_to_allow_assume](#input_repo_to_allow_assume)                                     | GitHub repository to allow Assume for this role.<br>(e.g. 'moajo/hoge-repo')                                                         | `string`       | n/a     |   yes    |
| <a name="input_role_name"></a> [role_name](#input_role_name)                                                                      | The name of the role                                                                                                                 | `string`       | n/a     |   yes    |

## Outputs

| Name                                            | Description      |
| ----------------------------------------------- | ---------------- |
| <a name="output_role"></a> [role](#output_role) | Created iam role |

<!-- END_TF_DOCS -->
