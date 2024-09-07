# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMPILE PROVISIO PACKAGES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = templatefile("${path.module}/templates/tags.tf.tftpl", {
    map_of_tags = merge(
      var.resource_tags,
      {
        "module_provider" = "ACAI GmbH",
        "module_name"     = "terraform-aws-acf-configservice",
        "module_source"   = "github.com/acai-consulting/terraform-aws-acf-configservice",
        "module_feature"  = "member",
        "module_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
      }
    )
  })

  non_primary_regions = tolist(setsubtract(var.provisio_settings.provisio_regions.regions, [var.provisio_settings.provisio_regions.primary_region]))
  delivery_target_s3  = try(var.aws_config_settings.delivery_channel_target.central_s3, null) != null
  bucket_kms_cmk_arn  = try(var.aws_config_settings.delivery_channel_target.central_s3.kms_cmk.arn, "")
  provisio_package_files = merge(
    {
      "requirements.tf" = templatefile("${path.module}/templates/requirements.tf.tftpl", {
        non_primary_regions  = local.non_primary_regions
        terraform_version    = ">= 1.5.7",
        provider_aws_version = ">= 5.00",
      })
      "aws_config.tf" = templatefile("${path.module}/templates/aws_config.tf.tftpl", {
        primary_region                        = var.provisio_settings.provisio_regions.primary_region
        non_primary_regions                   = local.non_primary_regions
        aggregation_account_id                = var.aws_config_settings.aggregation.aggregation_account_id
        config_iam_role_name                  = var.aws_config_settings.account_baseline.iam_role_name
        config_iam_role_path                  = var.aws_config_settings.account_baseline.iam_role_path
        config_recorder_name                  = var.aws_config_settings.account_baseline.recorder_name
        config_delivery_channel_name          = var.aws_config_settings.account_baseline.delivery_channel_name
        config_s3_delivery                    = local.delivery_target_s3
        config_s3_delivery_bucket_name        = local.delivery_target_s3 ? var.aws_config_settings.delivery_channel_target.central_s3.bucket_name : ""
        config_s3_delivery_bucket_kms_cmk_arn = local.bucket_kms_cmk_arn
        resource_tags                         = local.resource_tags
      })
    },
    var.provisio_settings.import_resources ? {
      "import.part" = templatefile("${path.module}/templates/import.part.tftpl", {
        primary_region                  = var.provisio_settings.provisio_regions.primary_region
        non_primary_regions             = local.non_primary_regions
        config_iam_role_name            = var.aws_config_settings.account_baseline.iam_role_name
        config_recorder_name            = var.aws_config_settings.account_baseline.recorder_name
        config_s3_delivery              = local.delivery_target_s3
        config_s3_delivery_channel_name = var.aws_config_settings.account_baseline.delivery_channel_name
      })
      } : {
      "import.part" : ""
    }
  )
}
