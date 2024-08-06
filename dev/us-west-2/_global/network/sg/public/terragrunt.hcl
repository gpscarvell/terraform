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
  name        = "${include.envcommon.locals.account.name}-worker-public-sg"
  description = "Allow public http(s) traffic to the worker nodes"

  ingress_cidr_blocks = ["0.0.0.0/0"] # Public access
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
}
