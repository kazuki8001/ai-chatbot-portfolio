# Lambda用のIAMロール
resource "aws_iam_role" "lambda_role" {
  name = "chatbot-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# BedrockのアクセスをLambdaに許可
resource "aws_iam_role_policy_attachment" "bedrock_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# CloudWatch Logsの許可
resource "aws_iam_role_policy_attachment" "logs_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambdaのコードをzip化
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

# Lambda関数
resource "aws_lambda_function" "chatbot" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "chatbot-terraform"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}