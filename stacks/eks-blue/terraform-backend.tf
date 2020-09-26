terraform {
  backend "s3" {
    bucket  = "<bucket_name>"
    key     = "terraform/stacks/<stack-name>.tfstate"
    region  = "<region>"
    profile = "<aws_profile>"
  }
}

