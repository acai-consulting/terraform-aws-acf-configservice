output "configuration_to_write" {
  value = {
    aggregation = module.aggregation.configuration_to_write.aggregation
    delivery_channel_target = module.delivery_channel_target_s3.configuration_to_write.delivery_channel_target
  }
}
