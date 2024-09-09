# ACAI ACF - AWS Config

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-consulting/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI" align="right" height="75" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
![module-version-shield]
[![Terraform Version][terraform-version-shield]][terraform-version-url]
![trivy-shield]
![checkov-shield]

<!-- DESCRIPTION -->
ACAI ACF specification-repo for AWS Config .


<!-- FEATURES -->
## Features

* AWS Config aggregation
* S3 bucket for delivery channel
* Multi-account, -region member configuration (requires ACAI PROVISIO)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_provisio_settings"></a> [provisio\_settings](#input\_provisio\_settings) | ACAI PROVISIO settings | <pre>object({<br>    provisio_package_name = optional(string, "account-hardening")<br>    provisio_regions = object({<br>      primary_region = string<br>      regions        = list(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_account_hardening_settings"></a> [account\_hardening\_settings](#input\_account\_hardening\_settings) | Account hardening settings | <pre>object({<br>    aws_account_password_policy = optional(<br>      object({<br>        # compliant with CIS AWS <br>        minimum_password_length        = optional(number, 16)<br>        minimum_password_length        = optional(number, 16)<br>        max_password_age               = optional(number, 90) # Recommended: 60 to 90 days<br>        password_reuse_prevention      = optional(number, 5)  # Recommended: prevent last 5 to 10 passwords<br>        require_lowercase_characters   = optional(bool, true)<br>        require_numbers                = optional(bool, true)<br>        require_uppercase_characters   = optional(bool, true)<br>        require_symbols                = optional(bool, true)<br>        allow_users_to_change_password = optional(bool, true)<br>      }),<br>      {<br>        minimum_password_length        = 16<br>        max_password_age               = 30<br>        password_reuse_prevention      = 24<br>        require_lowercase_characters   = true<br>        require_numbers                = true<br>        require_uppercase_characters   = true<br>        require_symbols                = true<br>        allow_users_to_change_password = true<br>      }<br>    )<br>    s3_account_level_public_access_block = optional(bool, true)<br>    ebs_encryption                       = optional(bool, true)<br>  })</pre> | <pre>{<br>  "aws_account_password_policy": {<br>    "allow_users_to_change_password": true,<br>    "max_password_age": 30,<br>    "minimum_password_length": 16,<br>    "password_reuse_prevention": 24,<br>    "require_lowercase_characters": true,<br>    "require_numbers": true,<br>    "require_symbols": true,<br>    "require_uppercase_characters": true<br>  },<br>  "ebs_encryption": true,<br>  "s3_account_level_public_access_block": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_provisio_packages"></a> [provisio\_packages](#output\_provisio\_packages) | n/a |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI][acai-url]

<!-- LICENSE -->
## License

This module is licensed by the customer based on the **ACAI Nutzungsvertrag PROVISIO**

<!-- COPYRIGHT -->
<br />
<br />
<p align="center">Copyright &copy; 2024 ACAI GmbH</p>

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.0.0-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.0-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[terraform-version-url]: https://www.terraform.io/upgrade-guides/1-3.html
[provisio-url: https://acai.gmbh/solutions/provisio
