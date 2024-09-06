# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region  = "eu-central-1"
  alias   = "workload"
  profile = "acai_testbed"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region  = "us-east-2"
  alias   = "workload_use2"
  profile = "acai_testbed"
  assume_role {
    role_arn = "arn:aws:iam::767398146370:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Workload Account
  }
}
