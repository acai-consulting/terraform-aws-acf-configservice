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
  })
  default = {
    aggregator_name      = "aws-config-aggregator"
    aggregator_role_name = "aws-config-aggregator-role"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ COMMON
# ---------------------------------------------------------------------------------------------------------------------
variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}
