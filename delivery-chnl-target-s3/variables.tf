variable "settings" {
  description = "Security Baseline Settings."
  type = object({
    aws_config = optional(object({
      s3_delivery = object({
        bucket_name          = string
        bucket_sse_algorithm = optional(string, "CMK")
        kms_cmk = optional(object({
          key_alias                   = optional(string, "aws-config-recorder-logs-key")
          additional_kms_cmk_grants   = string
          enable_iam_user_permissions = optional(bool, true)
        }), null)
        bucket_days_to_glacier    = optional(number, 30)
        bucket_days_to_expiration = optional(number, 180)
      })
      account_baseline = object({
        # compliant with CIS AWS 
        iam_role_name         = optional(string, "aws-config-recorder-role")
        iam_role_path         = optional(string, "/")
        recorder_name         = optional(string, "aws-config-recorder")
        delivery_channel_name = optional(string, "aws-config-recorder-delivery-channel")
      })
    }), null)
  })
}

variable "s3_delivery_bucket_force_destroy" {
  description = "This is for automated testing purposes only!"
  type        = optional(bool, false)
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}



variable "organization_id" {
  description = "AWS Organization Id."
  type        = string
}

variable "aggregation_aggregator_name" {
  description = "Name of the AWS Config Aggregator."
  type        = string
  default     = "foundation_aws_config_aggregator"
}

variable "aggregation_aggregator_role_name" {
  description = "Name of the IAM Role for the AWS Config Aggregator."
  type        = string
  default     = "foundation_aws_config_aggregator_role"
}

variable "logging_target_bucket_kms_cmk_grants" {
  default = null
}
