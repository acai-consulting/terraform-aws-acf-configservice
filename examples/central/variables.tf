variable "bucket_encryption" {
  description = "Provide 'CMK' or 'AES256'"
  type        = string
  default     = "CMK"
}