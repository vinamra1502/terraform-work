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
