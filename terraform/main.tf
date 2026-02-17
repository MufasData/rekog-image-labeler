provider "aws" {
  region = var.aws_region
}

# To create S3 bucket for images
resource "aws_s3_bucket" "image_bucket" {
  bucket = "${var.project_name}-${random_id.id.hex}"
}

resource "random_id" "id" {
    byte_length = 4
}

# Creating role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
    }]
  })
}

# Policy to access S3 and Rekognition
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.project_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.image_bucket.arn}/*"
      },
      {
        Action   = ["rekognition:DetectLabels"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach created policy to role
resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}