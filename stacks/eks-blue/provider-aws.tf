provider "aws" {
  alias   = "default"
  version = "~> 2.49"
  region  = "us-east-1"
  profile = "<bizzabo_profile>"
}

data "aws_region" "current" {
  provider = aws.default
}

data "aws_caller_identity" "current" {
  provider = aws.default
}

