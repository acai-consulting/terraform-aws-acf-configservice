output "member_settings" {
  description = "Settings to be provided to render member files."
  value = local.member_input
}

output "member_files" {
  description = "Rendered member files."
  value = module.member_files
}
