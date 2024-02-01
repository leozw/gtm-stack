terraform {
  ## Use for prd
  # backend "s3" {
  #   bucket    = ""
  #   key       = "tfstate"
  #   region    = ""
  #   profile   = ""
  # }

  required_version = ">= 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }
}