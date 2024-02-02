locals {
  policy_arns = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = [
            "${module.s3-mimir-ruler.bucket-arn}",
            "${module.s3-mimir.bucket-arn}"
            ],
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ],
        Resource = [
            "${module.s3-mimir-ruler.bucket-arn}/*",
            "${module.s3-mimir.bucket-arn}/*"
            ],
      },
    ],
  })
  policy_arn = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = [
            "${module.s3-tempo.bucket-arn}"
            ],
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ],
        Resource = [
            "${module.s3-tempo.bucket-arn}/*"
            ],
      },
    ],
  })
}