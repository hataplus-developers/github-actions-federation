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
    # MEMO: リポジトリ名だけで制御したい場合はこちら
    condition {
      test = "StringLike"
      variable = "vstoken.actions.githubusercontent.com:aud"
      values = [
        "https://github.com/${local.reponame}"
      ]
    }
    
    # MEMO: ブランチで制御したい場合はこちら（CIは走るがAssumeRoleWithWebIdentityに失敗してエラーになる）
    # condition {
    #   test = "StringLike"
    #   variable = "vstoken.actions.githubusercontent.com:sub"
    #   values = [
    #     "repo:${local.reponame}:ref:refs/heads/master"
    #   ]
    # }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://vstoken.actions.githubusercontent.com"
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
  client_id_list = ["https://github.com/${local.reponame}"]
}

resource "aws_iam_role" "main" {
  name = "iam.github-actions.federated"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
