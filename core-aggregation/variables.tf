variable "settings" {
  description = "Security Baseline Settings."
  type = object({
    aws_config = optional(object({
      aggregation = object({
        aggregator_name      = optional(string, "acf_config_aggregator")
        aggregator_role_name = optional(string, "acf_config_aggregator_role")
      })
    }), null)
    aws_security_hub = optional(object({


    }), null)
    amazon_guardduty = optional(object({


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
