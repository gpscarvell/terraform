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
  name        = "${include.envcommon.locals.account.name}-rds"
  description = "Allow db connections"

  ingress_cidr_blocks = concat(dependency.vpc.outputs.private_subnets_cidr_blocks, ["10.0.0.0/16"])
  ingress_rules       = ["postgresql-tcp"]

  # ingress_with_source_security_group_id = [
  #   {
  #     rule                     = "postgresql-tcp"
  #     source_security_group_id = "sg-0243c570f2e379b65" # bastion SG
  #   },
  # ]

  tags = {
    # Define custom tags here as key = "value"
  }
}
