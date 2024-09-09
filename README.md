# terraform-aws-acf-configservice Terraform module

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
[![module-version-shield]][module-release-url]
![terraform-version-shield]
![trivy-shield]
![checkov-shield]

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

* Central AWS Config Aggregator
* Central AWS Config Logging
* AWS Config Member Resources (via ACAI PROVISIO)

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

### Central Resources

```hcl
module "aggregation" {
  source = "../../aggregation"

  aws_config_settings = local.aws_config_settings
  providers = {
    aws = aws.core_security
  }
}

module "s3_delivery_channel" {
  source = "../../delivery-channel-target-s3"

  aws_config_settings = local.aws_config_settings
  providers = {
    aws = aws.core_logging
  }
}
```

### Render Member Resource-Package for ACAI PROVISIO

```hcl
module "member_package" {
  source = "../../member/acai-provisio"

  provisio_settings = {
    provisio_regions = local.regions_settings
  }
  aws_config_settings = local.aws_config_settings
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aggregation"></a> [aggregation](#module\_aggregation) | ./aggregation | n/a |
| <a name="module_delivery_channel_target_s3"></a> [delivery\_channel\_target\_s3](#module\_delivery\_channel\_target\_s3) | ./delivery-channe-target-s3 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_config_settings"></a> [aws\_config\_settings](#input\_aws\_config\_settings) | AWS Config- Aggregation Settings. | <pre>object({<br>    aggregation = optional(object({<br>      aggregator_name      = optional(string, "aws-config-aggregator")<br>      aggregator_role_name = optional(string, "aws-config-aggregator-role")<br>      }),<br>      {<br>        aggregator_name      = "aws-config-aggregator"<br>        aggregator_role_name = "aws-config-aggregator-role"<br>    })<br>    delivery_channel_target = object({<br>      central_s3 = object({<br>        bucket_name = string<br>        kms_cmk = optional(object({<br>          key_alias                   = optional(string, "aws-config-recorder-logs-key")<br>          deletion_window_in_days     = optional(number, 30)<br>          additional_kms_cmk_grants   = string<br>          enable_iam_user_permissions = optional(bool, true)<br>        }), null)<br>        bucket_days_to_glacier    = optional(number, 30)<br>        bucket_days_to_expiration = optional(number, 180)<br>      })<br>    })<br>    account_baseline = object({<br>      iam_role_name         = optional(string, "aws-config-recorder-role")<br>      iam_role_path         = optional(string, "/")<br>      recorder_name         = optional(string, "aws-config-recorder")<br>      delivery_channel_name = optional(string, "aws-config-recorder-delivery-channel")<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | A map of tags to assign to the resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_to_write"></a> [configuration\_to\_write](#output\_configuration\_to\_write) | n/a |
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
[module-release-url]: https://github.com/acai-consulting/terraform-aws-acf-configservice/releases
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[architecture]: ./docs/terraform-aws-acf-configservice.svg
[license-url]: https://github.com/acai-consulting/terraform-aws-acf-configservice/tree/main/LICENSE.md
[terraform-url]: https://www.terraform.io
[example-central-url]: ./examples/central
[example-member-provisio-rendered-url]: ./examples/member-provisio/rendered
[example-member-provisio]: ./examples/member-provisio
