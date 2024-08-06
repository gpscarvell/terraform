locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env_name = local.environment_vars.locals.environment.name
  account  = local.account_vars.locals.account
  prefix   = local.account_vars.locals.company.prefix
  dns_zone = local.account_vars.locals.dns_zone
  region   = local.region_vars.locals.region


  cluster_name    = local.account.name
  cluster_version = "1.24"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = find_in_parent_folders("components//compute/eks")
}

dependencies {
  paths = [
    find_in_parent_folders("_global/iam/role/eks-managed-node"),
    find_in_parent_folders("_global/network/vpc"),
    find_in_parent_folders("_global/network/sg/eks")
  ]
}

dependency "vpc" {
  config_path = find_in_parent_folders("_global/network/vpc")
}

dependency "eks_sg" {
  config_path = find_in_parent_folders("_global/network/sg/eks")
}


dependency "iam" {
  config_path = find_in_parent_folders("_global/iam/role/eks-managed-node")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  aws_account_id           = local.account.aws_account_id
  vpc_id                   = dependency.vpc.outputs.vpc_id
  control_plane_subnet_ids = dependency.vpc.outputs.private_subnets
  subnet_ids               = dependency.vpc.outputs.private_subnets

  create_iam_role                       = true
  iam_role_name                         = local.cluster_name
  cluster_endpoint_private_access       = true
  cluster_endpoint_private_access_cidrs = dependency.vpc.outputs.private_subnets_cidr_blocks
  cluster_endpoint_public_access        = true
  create_cloudwatch_log_group           = false
  cluster_enabled_log_types             = []

  cluster_security_group_name = local.cluster_name
  node_security_group_name    = local.cluster_name
  node_security_group_tags    = { "Name" = "${local.cluster_name}-eks_worker_sg" }

  manage_aws_auth_configmap = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      addon_version     = "v1.8.7-eksbuild.3"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      addon_version     = "v1.24.7-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      addon_version     = "v1.11.4-eksbuild.3"
      resolve_conflicts = "OVERWRITE"
    }
  }

  assumed_role = "arn:aws:iam::${local.account.aws_account_id}:role/OrganizationAccountAccessRole"

  # OIDC Identity provider
  cluster_identity_providers = {
    oidc-sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  aws_auth_accounts = []
  aws_auth_roles = [
    {
      rolearn  = dependency.iam.outputs.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account.aws_account_id}:role/OrganizationAccountAccessRole"
      username = "OrganizationAccountAccessRole"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account.aws_account_id}:role/developer"
      username = "developer"
      groups   = ["developer"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account.aws_account_id}:role/qa"
      username = "qa"
      groups   = ["qa"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account.aws_account_id}:role/sre"
      username = "sre"
      groups   = ["sre"]
    },
    {
      rolearn  = "arn:aws:iam::${local.account.aws_account_id}:role/sysadmin"
      username = "sysadmin"
      groups   = ["sysadmin"]
    },
  ]
  aws_auth_users = []
  aws_auth_accounts = [
    "${local.account.aws_account_id}"
  ]

  bucket                  = "${local.prefix}-${local.account.name}-loki"
  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Temp workaround for bug : double owned tag
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1986
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1810
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }


  eks_managed_node_group_defaults = {
    ami_type                              = "AL2_x86_64"
    disk_size                             = 50
    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = [dependency.eks_sg.outputs.security_group_id]
    create_iam_role                       = false
    iam_role_arn                          = dependency.iam.outputs.iam_role_arn
  }

  eks_managed_node_groups = {
    system = {
      name = "system"
      use_name_prefix = true

      ami_release_version = "1.24.10-20230304"
      capacity_type = "ON_DEMAND"
      instance_types = [
        "m5.large"]
      desired_size = 2
      max_size = 3
      min_size = 1

      subnet_ids = [
        dependency.vpc.outputs.private_subnets[0]]

      labels = {
        Environment = "system"
      }

      update_config = {
        max_unavailable_percentage = 100
        # or set `max_unavailable`
      }

      launch_template_tags = {
        "account" = local.account.name
        "jurisdiction" = local.account_vars.locals.jurisdiction
        "environment" = local.env_name
        "Terraform" = true
      }
    }
  }

  helm_charts = {


    argocd = {
      name       = "argocd"
      repository = "https://argoproj.github.io/argo-helm"
      chart      = "argo-cd"
      version    = "5.35.1"

      set = [
        {
        name  = "server.service.type"
        value = "ClusterIP"
        },

       {
        name  = "server.ingress.enabled"
        value = "false"
       },
       {
        name  = "admin.enabled"
        value = "false"
       }
      ]
    }

  }



  tags = {
    "service" = "eks"
  }
}
