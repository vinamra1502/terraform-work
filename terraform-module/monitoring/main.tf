resource "aws_sns_topic" "this" {
    name = "aws-${var.environment}-alerts-topic"
    display_name = "aws-${var.environment}-alerts-topic"



  tags = {
      Environment = var.environment
    }
}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "sns:Publish"

    ]


    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.this.arn
    ]
  }
}
resource "aws_iam_role" "chatbot_role" {
  name = "chatbot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "sid0"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "chatbot_policy" {
  name = "chatbot"
  role = aws_iam_role.chatbot_role.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action =  [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role" "alert_lambda_role" {
  name = "aws-pipeline-alerts-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "sid0"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda"
  role = aws_iam_role.alert_lambda_role.id


  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": "ssm:GetParameter",
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": "kms:Decrypt",
        "Effect": "Allow",
        "Resource": {
          "Fn::ImportValue": "Crypto:ExportsOutputFnGetAttopusonecmk5F3B6B70Arn765E2BE7"
        }
      },
      {
        "Action": "codepipeline:GetPipelineExecution",
        "Effect": "Allow",
        "Resource": "arn:aws:codepipeline:us-east-1:823208167079:*"
      }
    ]
      },

  )
}
