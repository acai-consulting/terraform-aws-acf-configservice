# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
      configuration_aliases = [
        aws.aggregation,
        aws.delivery_channel_target_s3
      ]
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ CALL SUB-MODULES
# ---------------------------------------------------------------------------------------------------------------------
module "aggregation" {
  source = "./aggregation"

  aws_config_settings = var.aws_config_settings
  resource_tags       = var.resource_tags
  providers = {
    aws = aws.aggregation
  }
}

module "delivery_channel_target_s3" {
  source = "./delivery-channe-target-s3"

  aws_config_settings = var.aws_config_settings
  resource_tags       = var.resource_tags
  providers = {
    aws = aws.delivery_channel_target_s3
  }
}