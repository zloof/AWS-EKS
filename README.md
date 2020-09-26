# Stacks

This repo is backed by a CircleCI workflow that allows changes without running
terraform locally on the developer's machine.

Stacks checklist:
1. Get AWS credentials and save them in `~/.aws/credentials`
1. check/update terraform backend file (forraform-backend.tf)
1. check/update provider-aws.tf file
1. create .tool-versions with all the required plugins
1. check all .tf files and fill the missing <variables>

How to make changes:

1. Understand [Terraform](https://www.terraform.io/)
1. Understand [`asdf-vm`](https://github.com/asdf-vm/asdf)
1. Create a feature branch
1. Commit your changes
1. Open a pull request on github and follow the checklist in it

How to run locally:

In some cases it's better to be able to run the plan locally.
This is also required in case you need to work directly with terraform's state
(ie. `terraform import`, `terraform state ...`)

**Do not run apply locally**. This must be done only in cases of emergency.

# Utils
Please check the README.md at the util folder

# Conventions

## DNS names

| Resource | DNS record format                     |
|----------|---------------------------------------|
| ELB      | `<elb-name>.<region>.bizzabo.com` |


## File names

1. use `-` instead of `_` in file names.

## Code style

1. use 2 soft spaces for indentation
1. use `_` instead of `-` in resource names (to match terraform's style)
