variable "aws_region" {
  default = "us-east-2"
}

variable "project_name" {
    default = "image-rekog-lab"
}

variable "confidence_threshold" {
  description = "The minimum confidence percentage for label detection"
  default = "80"
}