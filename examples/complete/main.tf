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

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  aws_config_settings = {
    aggregation = {
      aggregator_name      = "aws-config-aggregator"
      aggregator_role_name = "aws-config-aggregator-role"
    }
    delivery_channel_target = {
      central_s3 = {
        bucket_name = format("aws-config-logs-%s", data.aws_caller_identity.logging.account_id)
        kms_cmk = {
          key_alias                   = "aws-config-recorder-logs-key"
          deletion_window_in_days     = 30
          additional_kms_cmk_grants   = ""
          enable_iam_user_permissions = true
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
  depends_on = [
    module.delegation_euc1
  ]
}

module "s3_delivery_channel" {
  source = "../../delivery-chnl-target-s3"

  aws_config_settings = local.aws_config_settings
  providers = {
    aws = aws.core_logging
  }
}


locals {
  member_input = merge(local.aws_config_settings,
    {
      aggregation = merge(local.aws_config_settings.aggregation, {
        aggregation_account_id = data.aws_caller_identity.aggregation.account_id
      })
    },
    {
      delivery_channel_target = {
        central_s3 = merge(local.aws_config_settings.delivery_channel_target.central_s3, {
          kms_cmk = merge(local.aws_config_settings.delivery_channel_target.central_s3.kms_cmk, {
            arn = try(module.s3_delivery_channel.configuration_to_write.delivery_channel_target.central_s3.kms_cmk.arn, "")
          })
        })
      }
    }
  )
}


module "member_files" {
  source = "../../member/acai-provisio"

  provisio_settings = {
    provisio_regions = local.regions_settings
  }
  aws_config_settings = local.member_input

}
