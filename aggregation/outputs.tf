output "configuration_to_write" {
  value = {
    aggregation = {
      aggregation_account_id = data.aws_caller_identity.current.account_id
    }
  }
}
