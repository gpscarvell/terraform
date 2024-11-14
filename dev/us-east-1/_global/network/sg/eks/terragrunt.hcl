# ---------------------------------------------------------------------------------------------------------------------
# Include configurations that are common used across multiple environments.
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path           = "${find_in_parent_folders("_envcommon/network/sg")}//terragrunt.hcl"
  expose         = true
  merge_strategy = "deep"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name        = "${include.envcommon.locals.account.name}-worker-sg"
  description = "Allow http(s) traffic to the worker nodes"

  ingress_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block, "10.20.4.199/32", "10.0.0.0/16"] # VPC and VPN
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Node to node all ports/protocols"
      self        = true
    },
  ]
}
