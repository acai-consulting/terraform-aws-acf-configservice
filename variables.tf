variable "aws_config_settings" {
  description = "AWS Config- Aggregation Settings."
  type = object({
    aggregation = optional(object({
      aggregator_name      = optional(string, "aws-config-aggregator")
      aggregator_role_name = optional(string, "aws-config-aggregator-role")
      }),
      {
        aggregator_name      = "aws-config-aggregator"
        aggregator_role_name = "aws-config-aggregator-role"
    })
    delivery_channel_target = object({
      central_s3 = object({
        bucket_name = string
        kms_cmk = optional(object({
          key_alias                   = optional(string, "aws-config-recorder-logs-key")
          deletion_window_in_days     = optional(number, 30)
          additional_kms_cmk_grants   = string
          enable_iam_user_permissions = optional(bool, true)
        }), null)
        bucket_days_to_glacier    = optional(number, 30)
        bucket_days_to_expiration = optional(number, 180)
      })
    })
    account_baseline = object({
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
