variable "settings" {
  description = "Security Baseline Settings."
  type = object({
    aws_config = optional(object({
      aggregation = object({
        aggregator_name      = optional(string, "aws-config-aggregator")
        aggregator_role_name = optional(string, "aws-config-aggregator-role")
      })
    }), null)
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
