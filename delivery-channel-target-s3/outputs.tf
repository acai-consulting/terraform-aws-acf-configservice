output "configuration_to_write" {
  value = local.kms_cmk ? {
    delivery_channel_target = {
      central_s3 = {
        kms_cmk = {
          arn = aws_kms_key.aws_config_bucket_cmk[0].arn
        }
      }
    }
  } : {}
}