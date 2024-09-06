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
data "aws_caller_identity" "this" {}

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
      "module_feature"  = "core-logging",
      "module_version"  = /*inject_version_start*/ "1.0.0" /*inject_version_end*/
    }
  )  
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOGGING TARGET ACCOUNT - KMS KEY
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "aws_config_bucket_cmk" {
  count = var.settings.aws_config.s3_delivery.bucket_sse_algorithm == "CMK" ? 1 : 0
  description             = "Encryption key for object uploads to S3 bucket ${var.settings.aws_config.s3_delivery.bucket_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.aws_config_bucket_cmk.json
  tags                    = var.resource_tags
}

data "aws_iam_policy_document" "aws_config_bucket_cmk" {
  # enable IAM in logging account
  source_policy_documents = var.logging_target_bucket_kms_cmk_grants == null ? null : [var.logging_target_bucket_kms_cmk_grants]

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.logging_target.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # allow org master account to encrypt in the cloudtrail encryption context
  statement {
    sid    = "AWSConfigKMSPolicy"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["true"]
    }
    # TODO condition to restrict to Member AWS Config Roles only
  }
}

resource "aws_kms_alias" "aws_config_bucket_cmk" {
  name          = "alias/${replace(var.settings.aws_config.s3_delivery.bucket_name, ".", "-")}-key"
  target_key_id = aws_kms_key.aws_config_bucket_cmk.key_id
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOGGING TARGET ACCOUNT - AWS CONFIG AGGREGATOR BUCKET
# ---------------------------------------------------------------------------------------------------------------------
#tfsec:ignore:avd-aws-0089
resource "aws_s3_bucket" "aws_config_bucket" {
  #checkov:skip=CKV_AWS_144 : No Cross-Region Bucket replication 
  bucket        = var.settings.aws_config.s3_delivery.bucket_name
  force_destroy = var.settings.aws_config.s3_delivery.force_destroy
  tags          = local.resource_tags
}

resource "aws_s3_bucket_versioning" "aws_config_bucket" {
  bucket = aws_s3_bucket.aws_config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_config_bucket" {
  bucket = aws_s3_bucket.aws_config_bucket.id

  dynamic "rule" {
    for_each = var.settings.aws_config.s3_delivery.bucket_sse_algorithm == "CMK" ? [1] : []
    content {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.aws_config_bucket_key[0].id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  dynamic "rule" {
    for_each = var.settings.aws_config.s3_delivery.bucket_sse_algorithm == "AES256" ? [1] : []
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  } 
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_config_bucket" {
  #checkov:skip=CKV_AWS_300 : No Multipart Upload
  bucket = aws_s3_bucket.aws_config_bucket.id
  rule {
    id     = "Expiration"
    status = "Enabled"
    expiration {
      days = var.settings.aws_config.s3_delivery.days_to_expiration
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "aws_config_bucket" {
  bucket = aws_s3_bucket.aws_config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "awsconfig_bucket" {
  bucket   = resource.aws_s3_bucket.aws_config_bucket.id
  policy   = data.aws_iam_policy_document.awsconfig_bucket.json
  provider = aws.logging_target
}

data "aws_iam_policy_document" "awsconfig_bucket" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [resource.aws_s3_bucket.aws_config_bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        var.organization_id
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:userid"
      values = [
        replace(
          format(":role/%s%s", var.settings.aws_config.account_baseline.config_iam_role_path, var.settings.aws_config.account_baseline.config_iam_role_name), 
          "////", "/"
        )
      ]
    }
  }
 statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [resource.aws_s3_bucket.aws_config_bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        var.organization_id
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:userid"
      values = [
        replace(
          format(":role/%s%s", var.settings.aws_config.account_baseline.config_iam_role_path, var.settings.aws_config.account_baseline.config_iam_role_name), 
          "////", "/"
        )
      ]
    }
  }  
  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = [
      format("%s/AWSLogs/*/Config/*", resource.aws_s3_bucket.aws_config_bucket.arn),
      format("%s/*/AWSLogs/*/Config/*", resource.aws_s3_bucket.aws_config_bucket.arn)
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalIsAWSService"
      values   = ["true"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        var.organization_id
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:userid"
      values = [
        replace(
          format(":role/%s%s", var.settings.aws_config.account_baseline.config_iam_role_path, var.settings.aws_config.account_baseline.config_iam_role_name), 
          "////", "/"
        )
      ]
    }
  }

  dynamic "statement" {
    for_each = var.settings.aws_config.s3_delivery.bucket_sse_algorithm == "CMK" ? [1] : []
    content {
      sid    = "RequireKmsCmkEncryption"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = ["s3:PutObject"]
      resources = [
        format("%s/AWSLogs/*/Config/*", resource.aws_s3_bucket.aws_config_bucket.arn),
        format("%s/*/AWSLogs/*/Config/*", resource.aws_s3_bucket.aws_config_bucket.arn)
      ]
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values   = ["aws:kms"]
      }
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values   = [aws_kms_key.aws_config_bucket_cmk.arn]
      }
    }
  }
}