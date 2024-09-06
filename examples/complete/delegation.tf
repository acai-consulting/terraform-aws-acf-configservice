# ---------------------------------------------------------------------------------------------------------------------
# ¦ DELEGATIONS
# ---------------------------------------------------------------------------------------------------------------------
data "aws_region" "org_mgmt" {
  provider = aws.org_mgmt
}

locals {
  delegations = [
    {
      regions            = local.regions_settings.regions
      aggregation_region = local.regions_settings.primary_region
      service_principal  = "config.amazonaws.com"
      target_account_id  = data.aws_caller_identity.aggregation.account_id
    }
  ]
}


module "delegation_preprocess_data" {
  source = "git::https://github.com/acai-consulting/terraform-aws-acf-org-delegation.git//modules/preprocess-data?ref=1.0.3"

  primary_aws_region = local.regions_settings.primary_region
  delegations        = local.delegations
}


module "delegation_euc1" {
  source = "git::https://github.com/acai-consulting/terraform-aws-acf-org-delegation.git?ref=1.0.3"

  primary_aws_region = module.delegation_preprocess_data.is_primary_region[data.aws_region.org_mgmt.name]
  delegations        = module.delegation_preprocess_data.delegations_by_region[data.aws_region.org_mgmt.name]
  providers = {
    aws = aws.org_mgmt
  }
}
