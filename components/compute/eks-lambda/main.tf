terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.53.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }
}

# Create zip-archive of a single directory where "pip install" will also be executed (default for python runtime)
module "package_dir" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-lambda.git?ref=v2.17.0"

  create_function = false

  runtime = "python3.7"
  source_path = [
    "${path.module}/lambda_source/index.py",
    # {
    #   pip_requirements = "${path.module}/lambda_source/requirements.txt"
    # }
  ]

  build_in_docker = false

  tags = var.tags
}

module "eks_scale" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-lambda.git?ref=v2.17.0"

  function_name = var.function_name
  role_name     = var.role_name
  description   = var.description
  handler       = "index.lambda_handler"
  runtime       = "python3.7"
  publish       = false

  create_package         = false
  local_existing_package = module.package_dir.local_filename

  memory_size = 128

  attach_policy_statements = true
  policy_statements = {
    eks = {
      effect = "Allow",
      actions = [
        "eks:DescribeNodegroup",
        "eks:UpdateNodegroupConfig"
      ],
      resources = ["arn:*:eks:*"]
    },
  }

  attach_network_policy  = false

  tags = var.tags
}
