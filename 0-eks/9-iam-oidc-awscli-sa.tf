# This is mostly to test OIDC, you can use it as an eg for aws cli implemntation in pod
data "aws_iam_policy_document" "surek8scmnsapolicydoc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.surek8soidcprovider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-cli-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.surek8soidcprovider.arn]
      type        = "Federated"
    }
  }
}

# IAM role to access resources by AWS cli pod

resource "aws_iam_role" "surek8sawsclisaiamrole" {
  assume_role_policy = data.aws_iam_policy_document.surek8scmnsapolicydoc.json
  name               = "sure-k8s-aws-cli-sa-iam-role"
}

resource "aws_iam_policy" "surek8sawsclisaiampolicy" {
  name = "sure-k8s-aws-cli-sa-iam-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Effect   = "Allow"
      Resource = "arn:aws:s3:::*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "surek8sawsclisaiampolicyattach" {
  role       = aws_iam_role.surek8sawsclisaiamrole.name
  policy_arn = aws_iam_policy.surek8sawsclisaiampolicy.arn
}

output "surek8sawsclisaiamrolearn" {
  value = aws_iam_role.surek8sawsclisaiamrole.arn
}
