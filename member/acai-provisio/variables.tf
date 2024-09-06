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
    delivery_channel_target = object({
      central_s3 = optional(object({
        bucket_name = string
        kms_cmk = optional(object({
          arn = optional(string, "")
        }), null)
      }), null)
    })
    account_baseline = object({
      # compliant with CIS AWS 
      iam_role_name         = optional(string, "aws-config-recorder-role")
      iam_role_path         = optional(string, "/")
      recorder_name         = optional(string, "aws-config-recorder")
      delivery_channel_name = optional(string, "aws-config-recorder-delivery-channel")
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
