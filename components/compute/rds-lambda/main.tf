terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.0.9"

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

module "rds_start_stop" {
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

  environment_variables = {
    database = var.database_id
    region   = var.lambda_region
  }

  attach_policy_statements = true
  policy_statements = {
    rds = {
      effect = "Allow",
      actions = [
        "rds:DescribeDBClusterParameters",
        "rds:StartDBCluster",
        "rds:StopDBCluster",
        "rds:DescribeDBEngineVersions",
        "rds:DescribeGlobalClusters",
        "rds:DescribePendingMaintenanceActions",
        "rds:DescribeDBLogFiles",
        "rds:StopDBInstance",
        "rds:StartDBInstance",
        "rds:DescribeReservedDBInstancesOfferings",
        "rds:DescribeReservedDBInstances",
        "rds:ListTagsForResource",
        "rds:DescribeValidDBInstanceModifications",
        "rds:DescribeDBInstances",
        "rds:DescribeSourceRegions",
        "rds:DescribeDBClusterEndpoints",
        "rds:DescribeDBClusters",
        "rds:DescribeDBClusterParameterGroups",
        "rds:DescribeOptionGroups"
      ],
      resources = [var.database_arn]
    },
  }

  attach_network_policy  = false

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "stop_db" {
  name                = "${var.function_name}-stop-db"
  description         = "Stops db"
  schedule_expression = "cron(${var.work_period_end})"

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "start_db" {
  name                = "${var.function_name}-start-db"
  description         = "Starts db"
  schedule_expression = "cron(${var.work_period_start})"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "stop_db" {
  rule  = aws_cloudwatch_event_rule.stop_db.name
  arn   = module.rds_start_stop.lambda_function_arn
  input = "{\"action\":\"stop\"}"
}

resource "aws_cloudwatch_event_target" "start_db" {
  rule  = aws_cloudwatch_event_rule.start_db.name
  arn   = module.rds_start_stop.lambda_function_arn
  input = "{\"action\":\"start\"}"
}

resource "aws_lambda_permission" "allow_stop_db_to_call_check" {
  statement_id  = "${var.function_name}-stop-db-AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.rds_start_stop.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_db.arn
}

resource "aws_lambda_permission" "allow_start_db_to_call_check" {
  statement_id  = "${var.function_name}-start-db-AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.rds_start_stop.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_db.arn
}
