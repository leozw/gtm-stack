provider "aws" {
  profile = ""
  region  = ""
}

locals {
  # environment
  environment = ""
}

data "aws_eks_cluster" "this" {
  # cluster_name
  name = ""
}

data "aws_eks_cluster_auth" "this" {
  # cluster_name
  name = ""
}

module "s3-tempo" {
  source = "./modules/s3"

  name_bucket = "tempo-bucket-test"
  environment = local.environment
}

module "s3-mimir" {
  source = "./modules/s3"

  name_bucket = "mimir-bucket-test"
  environment = local.environment
}

module "iam-tempo" {
  source = "./modules/iam"

  iam_roles = {
    "tempo-${local.environment}" = {
      "openid_connect" = "${data.aws_iam_openid_connect_provider.this.arn}"
      "openid_url"     = "${data.aws_iam_openid_connect_provider.this.url}"
      "serviceaccount" = "tempo"
      "string"         = "StringEquals"
      "namespace"      = "lgtm"
      "policy" = templatefile("${path.module}/templates/policy-lgtm.json", {
        bucket_name = module.s3-tempo.bucket-name
      })
    }
  }

}

module "iam-mimir" {
  source = "./modules/iam"

  iam_roles = {
    "mimir-${local.environment}" = {
      "openid_connect" = "${data.aws_iam_openid_connect_provider.this.arn}"
      "openid_url"     = "${data.aws_iam_openid_connect_provider.this.url}"
      "serviceaccount" = "mimir"
      "string"         = "StringEquals"
      "namespace"      = "lgtm"
      "policy" = templatefile("${path.module}/templates/policy-lgtm.json", {
        bucket_name = module.s3-mimir.bucket-name
      })
    }
  }
}