# terraform-aws-github-actions-federation-role

This is terraform module to create an iam role that can be assumeRole from github actions of a specific repository.

see: https://awsteele.com/blog/2021/09/15/aws-federation-comes-to-github-actions.html

# usage

```tf
module "federation_role" {
  source            = "git@github.com:moajo/terraform-aws-github-actions-federation-role.git"
  role_name         = "hoge"
  organization_name = "moajo"
  repository_name   = "terraform-aws-github-actions-federation-role"
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
  AWS_DEFAULT_REGION: us-east-1
  AWS_ROLE_ARN: arn:aws:iam::xxxxxxxxxxxx:role/hoge
  AWS_WEB_IDENTITY_TOKEN_FILE: /tmp/awscreds

jobs:
  get-caller-identity:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS
        run: |
          curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -r '.value' > $AWS_WEB_IDENTITY_TOKEN_FILE
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

| Name                                                                                                                                                      | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                 | resource |

## Inputs

| Name                                                                                 | Description                  | Type     | Default | Required |
| ------------------------------------------------------------------------------------ | ---------------------------- | -------- | ------- | :------: |
| <a name="input_organization_name"></a> [organization_name](#input_organization_name) | The name of the organization | `string` | n/a     |   yes    |
| <a name="input_repository_name"></a> [repository_name](#input_repository_name)       | The name of the repository   | `string` | n/a     |   yes    |
| <a name="input_role_name"></a> [role_name](#input_role_name)                         | The name of the role         | `string` | n/a     |   yes    |

## Outputs

| Name                                            | Description      |
| ----------------------------------------------- | ---------------- |
| <a name="output_role"></a> [role](#output_role) | Created iam role |

<!-- END_TF_DOCS -->
