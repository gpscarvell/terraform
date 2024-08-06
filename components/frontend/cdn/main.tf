terraform {
  # NOTE: The second `=` in the string is intentional, and it means
  # exactly version 0.15.0. In other words, we are setting the
  # required_version property of the terraform block to "= 0.15.0".
  required_version = "= 1.1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
}

module "cloudfront" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-cloudfront.git?ref=v2.5.0"

  aliases = var.aliases

  comment             = var.comment
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  retain_on_delete    = var.retain_on_delete
  wait_for_deployment = var.wait_for_deployment
  default_root_object = var.default_root_object

  create_origin_access_identity = var.create_origin_access_identity
  origin_access_identities = {
    s3_bucket_one = "${var.domain_name}"
  }

  logging_config = var.logging_config

  origin = {
    s3_one = {
      domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one" # key in `origin_access_identities`
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_one"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = var.ordered_cache_behavior
  custom_error_response  = var.custom_error_response

  viewer_certificate = {
    acm_certificate_arn = module.acm.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  geo_restriction = var.geo_restriction

  tags = var.tags
}

######
# ACM
######

data "aws_route53_zone" "this" {
  name = var.zone_name
}

module "acm" {
  source  = "git::git@github.com:terraform-aws-modules/terraform-aws-acm.git?ref=v3.0.0"

  providers = {
    aws = aws.us-east-1
  }

  domain_name               = var.domain_name
  zone_id                   = data.aws_route53_zone.this.id

  tags = var.tags
}

#############
# S3 buckets
#############

module "s3_one" {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v2.4.0"

  bucket = var.bucket
  acl    = var.acl

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  tags = var.tags
}

##########
# Route53
##########

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.this.id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

###########################
# Origin Access Identities
###########################
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject*"]
    resources = ["${module.s3_one.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_one.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
