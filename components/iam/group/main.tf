module "iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.9.2"

  name = var.name

  assumable_roles = var.assumable_roles

  tags = var.tags
}

####################################################
# Extending policies of IAM group
####################################################
module "iam_group_with_custom_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.9.2"

  name = module.iam_group.group_name

  create_group = false

  custom_group_policy_arns = var.custom_group_policy_arns

  tags = var.tags
}
