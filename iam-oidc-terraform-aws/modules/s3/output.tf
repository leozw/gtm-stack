output "bucket-name" {
  description = "The name bucket"
  value       = aws_s3_bucket.this.bucket
}