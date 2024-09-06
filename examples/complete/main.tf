# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "aggregation" {
  provider = aws.core_security
}
data "aws_caller_identity" "logging" {
  provider = aws.core_logging
}
data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  aws_config_settings = {
    aggregation = {
      aggregator_name        = "aws-config-aggregator"
      aggregator_role_name   = "aws-config-aggregator-role"
      aggregation_account_id = try(var.aws_config_configuration.aggregation.aggregation_account_id, local.core_accounts.security)
    }
    delivery_channel_target = {
      central_s3 = {
        bucket_name = format("aws-config-logs-%s", data.aws_caller_identity.logging.account_id)
        kms_cmk = {
          key_alias                   = "aws-config-recorder-logs-key"
          deletion_window_in_days     = 30
          additional_kms_cmk_grants   = ""
          enable_iam_user_permissions = true
          arn                         = try(var.aws_config_configuration.delivery_channel_target.central_s3.kms_cmk.arn, null)
        }
        bucket_days_to_glacier    = 90
        bucket_days_to_expiration = 360
      }
    }
    account_baseline = {
      iam_role_name         = "aws-config-recorder-role"
      iam_role_path         = "/"
      recorder_name         = "aws-config-recorder"
      delivery_channel_name = "aws-config-recorder-delivery-channel"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "aggregation" {
  source = "../../aggregation"

  aws_config_settings = local.aws_config_settings
  providers = {
    aws = aws.core_security
  }
}

module "s3_delivery_channel" {
  source = "../../delivery-chnl-target-s3"

  aws_config_settings = local.aws_config_settings
  providers = {
    aws = aws.core_logging
  }
}