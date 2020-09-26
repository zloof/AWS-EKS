locals {
  kube_admin_user = [
    {
        userarn = data.aws_iam_user.eks_master_user1.arn,
        username = data.aws_iam_user.eks_master_user1.user_name,
        groups: ["system:masters"]
    }]
}

data "aws_iam_user" "eks_master_user1" {
  provider  = aws.default
  user_name = "<user-name>"
}
