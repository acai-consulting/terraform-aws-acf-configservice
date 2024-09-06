# ---------------------------------------------------------------------------------------------------------------------
# ¦ REQUIREMENTS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  resource_tags = merge(
    var.resource_tags,
    {
      "module_provider" = "ACAI GmbH",
      "module_name"     = "terraform-aws-acf-configservice",
      "module_source"   = "github.com/acai-consulting/terraform-aws-acf-configservice",
      "module_feature"  = "core-aggregation",
      "module_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
    }
  )
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ AWS CONFIG AGGREGATOR ROLE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "aws_config_aggregator_role" {
  name               = var.settings.aws_config.aggregation.aggregator_role_name
  assume_role_policy = data.aws_iam_policy_document.aws_config_aggregator_role_trust.json
}

data "aws_iam_policy_document" "aws_config_aggregator_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "aws_config_aggregator_role_permissions" {
  role       = aws_iam_role.aws_config_aggregator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ AWS CONFIG AGGREGATOR
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_config_configuration_aggregator" "aws_config_aggregator" {
  name = var.settings.aws_config.aggregation.aggregator_name
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.aws_config_aggregator_role.arn
  }
  depends_on = [
    aws_iam_role_policy_attachment.aws_config_aggregator_role_permissions
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ SECURITY HUB - AGGREGATOR
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_securityhub_finding_aggregator" "sh_aggregator" {
  count        = can(var.settings.aws_security_hub) ? 1 : 0
  linking_mode = "ALL_REGIONS"
}

resource "aws_securityhub_organization_configuration" "sh_aggregator" {
  count                 = can(var.settings.aws_security_hub) ? 1 : 0
  auto_enable           = false
  auto_enable_standards = "DEFAULT"
  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.sh_aggregator[0]]
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ GUARDDUTY - AGGREGATOR
# ---------------------------------------------------------------------------------------------------------------------
data "aws_guardduty_detector" "gd_aggregator" {
  count = can(var.settings.amazon_guardduty) ? 1 : 0
}

resource "aws_guardduty_organization_configuration" "gd_aggregator" {
  count                            = can(var.settings.amazon_guardduty) ? 1 : 0
  detector_id                      = data.aws_guardduty_detector.gd_aggregator[0].id
  auto_enable_organization_members = "ALL"
}

