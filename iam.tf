locals {
  reponame = "aibou/github-actions-federation"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.reponame}:*"
      ]
    }
  }
}

# 同一AWSアカウント内に複数のこのURLでのIDプロバイダを作成できないため、このIDプロバイダを共有することになる
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
  client_id_list = ["sigstore"] # Question: GitHub ActionsのWorkflow内から叩くcurlに付与しているparamsの値と一致させる必要がある？
}

resource "aws_iam_role" "main" {
  name = "iam.github-actions.federated"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
