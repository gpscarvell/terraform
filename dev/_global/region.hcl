# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  region = {
    aws_region   = "us-east-1"
    state_region = "us-east-1"
  }
}
