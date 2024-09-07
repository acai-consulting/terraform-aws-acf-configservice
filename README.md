# terraform-aws-acf-configservice Terraform module

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url] 
![module-version-shield]
![terraform-version-shield]
![trivy-shield]
![checkov-shield]
[![Latest Release][release-shield]][release-url]

<!-- LOGO -->
<div style="text-align: right; margin-top: -60px;">
<a href="https://acai.gmbh">
  <img src="https://github.com/acai-consulting/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI"  width="250" /></a>
</div>
</br>

<!-- DESCRIPTION -->
[Terraform][terraform-url] module to deploy the central and de-central resources for AWS Config.


<!-- ARCHITECTURE -->
## Architecture

![architecture][architecture]

<!-- FEATURES -->
## Features
* Central Aggregator
* Central Logging
* Member Resources (via ACAI PROVISIO)

<!-- USAGE -->
## Usage

### Settings

```hcl
# ¦ security - aws_config
aws_config = {
  aggregation = {
    aggregator_name        = "aws-config-aggregator"
    aggregator_role_name   = "aws-config-aggregator-role"
    aggregation_account_id = try(var.aws_config_configuration.aggregation.aggregation_account_id, local.core_accounts.security) 
  }
  delivery_channel_target = {    
    central_s3 = {
      bucket_name               = format("aws-config-logs-%s", local.core_accounts.logging)
      kms_cmk = {
        key_alias                   = "aws-config-recorder-logs-key"
        deletion_window_in_days     = 30
        additional_kms_cmk_grants   = ""
        enable_iam_user_permissions = true
        arn = try(var.aws_config_configuration.delivery_channel_target.central_s3.kms_cmk.arn, null)
      }
      bucket_days_to_glacier    = 90
      bucket_days_to_expiration = 360
    }
  }
  account_baseline = {
    iam_role_name         = "aws-config-recorder-role"
    iam_role_path         = "/"
    recorder_name         = "aws-config-recorder"
    delivery_channel_name = "aws-config-recorder-delivery-channel"
  }
}
```


<!-- EXAMPLES -->
## Examples

First run this: [`examples/central`][example-central-url]
it will render the member Terraform files to here [`examples/member-provisio/rendered`][example-member-provisio-rendered-url]

Then run this: [`examples/member-provisio`][example-member-provisio]

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | account\_id |
| <a name="output_input"></a> [input](#output\_input) | pass through input |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url].

<!-- LICENSE -->
## License

See [LICENSE][license-url] for full details.

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.0.0-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[release-shield]: https://img.shields.io/github/v/release/acai-consulting/terraform-aws-acf-idc?style=flat&color=success
[architecture]: ./docs/terraform-aws-acf-configservice.svg
[release-url]: https://github.com/acai-consulting/REPLACE_ME/releases
[license-url]: https://github.com/acai-consulting/terraform-aws-acf-idc/tree/main/LICENSE.md
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
[example-central-url]: ./examples/central
[example-member-provisio-rendered-url]: ./examples/member-provisio/rendered
[example-member-provisio]: ./examples/member-provisio
