# Set common variables for the network. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  network = {
    cidr_prefix = "10.11"
  }
}
