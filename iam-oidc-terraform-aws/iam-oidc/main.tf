provider "aws" {
  profile = ""
  region  = "us-east-1"
}

locals {
  environment = "stg"
}

data "aws_eks_cluster" "this" {
  name = "k8s"
}

data "aws_eks_cluster_auth" "this" {
  name = "k8s"
}

module "s3-tempo" {
  source = "./modules/s3"

  name_bucket = "eks-lgtm-tempo-bucket"
  environment = local.environment
}

module "s3-mimir" {
  source = "./modules/s3"

  name_bucket = "eks-lgtm-mimir-bucket"
  environment = local.environment
}

module "s3-mimir-ruler" {
  source = "./modules/s3"

  name_bucket = "eks-lgtm-mimir-ruler-bucket"
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
      "policy"         = local.policy_arns
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
      "policy"         = local.policy_arns
    }
  }
}

