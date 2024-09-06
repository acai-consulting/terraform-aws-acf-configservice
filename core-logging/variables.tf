variable "settings" {
  description = "Security Baseline Settings."
  type = object({
    aws_config = optional(object({
      s3_delivery = object({
        bucket_name = string
        bucket_sse_algorithm = string
        bucket_days_to_glacier = optional(number, 30)
        bucket_days_to_expiration = optional(number, 180)
        force_destroy = optional(bool, false)
      })
      account_baseline = object({
        # compliant with CIS AWS 
        config_iam_role_name     = optional(string, "acf-config-recorder-role")
        config_iam_role_path     = optional(string, "/")
        config_recorder_name     = optional(string, "acf-config-recorder")
        delivery_channel_name    = optional(string, "acf-config-recorder-delivery-channel")
      })
    }), null)
  })
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

variable "logging_target_bucket_name" {
  description = "Globally unique name of the S3 bucket."
  type        = string
  default     = "foundation_aws_config_aggregator_logs"
}

variable "logging_target_bucket_days_to_glacier" {
  description = "Number of days until data is archived in glacier. If not set, data is never archived to glacier"
  type        = number
  default     = 90
}

variable "logging_target_bucket_days_to_expiration" {
  description = "Number of days until data is deleted. If not set, data is never deleted"
  type        = number
  default     = 360
}

variable "logging_target_bucket_kms_cmk_grants" {
  default = null
}

variable "member_recorder_name" {
  description = "Name of the Member AWS Config Recorder."
  type        = string
  default     = "foundation_aws_config_recorder"
}

variable "member_role_name" {
  description = "Name of the Member IAM role."
  type        = string
  default     = "foundation_aws_config_recorder_role"
}

variable "member_role_path" {
  description = "Path of the Member IAM role."
  type        = string
  default     = "/"
}

variable "member_delivery_channel_name" {
  description = "Name of the AWS Config Recorder delivery channel."
  type        = string
  default     = "foundation_aws_config_s3_delivery"
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
