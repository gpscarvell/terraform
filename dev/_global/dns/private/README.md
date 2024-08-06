# IMPORTANT

VPC in another account has to be assosiated:
See https://aws.amazon.com/premiumsupport/knowledge-center/route53-private-hosted-zone/

1. Comment VPN VPC in terragrunt.hcl:
```
      ...
      vpc = [
        {
          vpc_id     = dependency.vpc.outputs.vpc_id
          vpc_region = local.region.aws_region
        },
        # {
        #   vpc_id     = "vpc-093405bea014f23b2"
        #   vpc_region = "us-east-1"
        # },
      ]
      ...
```
2. Run terragrunt apply to create hosted zone.
3. Grab hosted zone id from output.
4. Create vpc association authorization (replace profile and hosted zone id with a value from previous step)
```
aws --profile staging route53 create-vpc-association-authorization --hosted-zone-id=Z04787633AVD5AHYRZLTS --vpc VPCRegion=us-east-1,VPCId=vpc-093405bea014f23b2
```
5. Uncomment VPN VPC in terragrunt.hcl
```
      ...
      vpc = [
        {
          vpc_id     = dependency.vpc.outputs.vpc_id
          vpc_region = local.region.aws_region
        },
        {
          vpc_id     = "vpc-093405bea014f23b2"
          vpc_region = "us-east-1"
        },
      ]
      ...
```
6. Apply changes.
