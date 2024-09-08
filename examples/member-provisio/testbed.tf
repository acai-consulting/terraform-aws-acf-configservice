# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
  alias  = "workload"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "workload_use2"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# ¦ BACKEND
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "remote" {
    organization = "acai"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-testbed"
    }
  }
}
