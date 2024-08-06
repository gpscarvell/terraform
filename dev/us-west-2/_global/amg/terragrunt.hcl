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
  path           = "${find_in_parent_folders("_envcommon/amg")}//terragrunt.hcl"
  expose         = true
  merge_strategy = "deep"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  role_associations = {
    "ADMIN" = {
      "group_ids" = ["28e17370-f091-7075-e04a-8d8b5ea44d6e"] # nonprod-grafana-admins
    }
    "EDITOR" = {
      "group_ids" = ["f8c123b0-e0c1-708d-9f11-ec601251cb76"] # nonprod-grafana-editors
    }
    "VIEWER" = {
      "group_ids" = ["38015300-6051-703b-09db-9e04ba415be6"] # nonprod-grafana-viewers
    }
  }
}
