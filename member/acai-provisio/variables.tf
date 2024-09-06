variable "provisio_settings" {
  description = "ACAI PROVISIO settings"
  type = object({
    provisio_package_name = optional(string, "aws-config")
    provisio_regions = object({
      primary_region = string
      regions        = list(string)
    })
    import_resources = optional(bool, false)
  })
}

variable "aws_config_settings" {
  description = "Account hardening settings"
  type = object({
    aggregation = object({
      aggregation_account_id = string
    })
    s3_delivery = optional(object({
      bucket_name           = string
      bucket_kms_cmk_arn    = string
    }), null)
    account_baseline = object({
      # compliant with CIS AWS 
      config_iam_role_name     = optional(string, "acf-config-recorder-role")
      config_iam_role_path     = optional(string, "/")
      config_recorder_name     = optional(string, "acf-config-recorder")
      delivery_channel_name    = optional(string, "acf-config-recorder-delivery-channel")
    })
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}