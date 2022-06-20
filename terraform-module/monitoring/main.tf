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
  description = "role for aws-pipeline-alerts lambda"
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
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "Sid0",
              "Effect": "Allow",

              "Action": [
                   "kms:Decrypt"
              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid1",
              "Effect": "Allow",

              "Action": [

                   "codepipeline:GetPipelineExecution"

              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid2",
              "Effect": "Allow",

              "Action": [

                   "ssm:GetParameter"

              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid3",
              "Effect": "Allow",

              "Action": [

              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"

              ],
              "Resource": "*"
          }

      ]
  }
EOF
}
resource "aws_lambda_function" "lambda" {
  function_name    = "aws-pipeline-alerts-lambda"
  depends_on       = [aws_iam_role.alert_lambda_role]
  filename         = "${path.module}/infrastructurefunctionsawspipelinesalerts.zip"
  handler          = "index.handler"
  role             =  aws_iam_role.alert_lambda_role.arn
  runtime          = "nodejs12.x"
  memory_size      = 512
  timeout          = 60

  environment {
    variables = {
      ENV = "dev"
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = 1
    }
  }
}
resource "aws_cloudwatch_event_rule" "this" {
  name        = "aws-pipeline-alerts-event-trigger"
  description = "Triggers aws-pipeline-alerts Lambda when CodePipeline reports Action Execution failures."
  is_enabled  = "true"


  event_pattern = <<PATTERN
{
    "source": ["aws.codepipeline"],
    "detail-type": ["CodePipeline Action Execution State Change"],
    "detail": {
      "state": ["FAILED"]
      }
}
PATTERN
}
resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  target_id = "Target0"
  arn = aws_lambda_function.lambda.arn
}
resource "aws_lambda_permission" "this" {
    statement_id = "AllowExecutionFromCloudWatchEventRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.this.arn
}
resource "aws_iam_role" "missingalert_lambda_role" {
  name = "missing-audit-log-lambda-role"
  description = "role for missing-audit-log lambda"
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
resource "aws_iam_role_policy" "missinglambda_policy" {
  name = "missinglambda"
  role = aws_iam_role.missingalert_lambda_role.id
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "Sid0",
              "Effect": "Allow",

              "Action": [
                   "kms:Decrypt"
              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid1",
              "Effect": "Allow",

              "Action": [

                 "ec2:DescribeInstances",
                 "ec2:CreateNetworkInterface",
                 "ec2:AttachNetworkInterface",
                 "ec2:DescribeNetworkInterfaces",
                 "ec2:DeleteNetworkInterface"

              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid2",
              "Effect": "Allow",

              "Action": [

                   "ssm:GetParameter"

              ],
              "Resource": "*"
          },
          {
              "Sid": "Sid3",
              "Effect": "Allow",

              "Action": [

              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"

              ],
              "Resource": "*"
          }

      ]
  }
EOF
}
resource "aws_security_group" "missinglambdasg" {
  name        = "missingauditloglambdaSecurityGroup"
  depends_on       = [aws_iam_role.missingalert_lambda_role]
  description = "Automatic security group for Lambda Function missingaudit log"
  vpc_id      =  var.vpc_id
  egress {
    description      = "Allow all outbound traffic by default"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 }
}
resource "aws_lambda_function" "missingauditlambda" {
  function_name    = "missing-audit-log-lambda"
  depends_on       = [aws_iam_role.missingalert_lambda_role]
  filename         = "${path.module}/infrastructurefunctionsawsmissingauditlogalerts.zip"
  handler          = "index.handler"
  role             =  aws_iam_role.missingalert_lambda_role.arn
  runtime          = "nodejs12.x"
  memory_size      = 512
  timeout          = 60

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.missinglambdasg.id]
  }


  environment {
    variables = {
      ENV = "dev"
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = 1
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "missingaudit" {
  alarm_name          = "missing-audit-log-lambda"
  alarm_description   = "missing-audit-log-lambda test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.missingauditlambda.function_name
  }

  alarm_actions     = [aws_sns_topic.this.arn]
}
resource "aws_cloudwatch_event_rule" "missingaudit" {
  name                = "missing-audit-log-lambda-alarm-trigger"
  description         = "Triggers Missing Audit Log Alarm"
  is_enabled          = "true"
  schedule_expression = "cron(30 13 * * ? *)"
}
resource "aws_cloudwatch_event_target" "missingaudit" {
  rule = aws_cloudwatch_event_rule.missingaudit.name
  target_id = "Target0"
  arn = aws_lambda_function.missingauditlambda.arn
}
resource "aws_lambda_permission" "missingaudit" {
    statement_id = "AllowExecutionFromCloudWatchEventRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.missingauditlambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.missingaudit.arn
}
resource "aws_config_config_rule" "config_rule" {
  name = "ConfigRule"
  count = length(var.source_identifier)
  description   = var.source_identifier[count.index]
  source {
    owner             = "AWS"
    source_identifier = var.source_identifier[count.index]
  }
}
resource "aws_cloudwatch_event_rule" "alert" {
  name        = "config-noncompliant-rule"
  description = "Rule triggers when config rule status changes to noncompliant"
  is_enabled  = "true"


  event_pattern = <<PATTERN
{
      "source": ["aws.config"],
      "detail-type": ["Config Rules Compliance Change"],
      "detail": {
        "messageType": ["ComplianceChangeNotification"],
        "newEvaluationResult": {
          "complianceType": ["NON_COMPLIANT"]
          }
      }
}
PATTERN
}
resource "aws_cloudwatch_event_target" "alert" {
  rule = aws_cloudwatch_event_rule.alert.name
  target_id = "Target0"
  arn = aws_sns_topic.this.arn
}
resource "aws_cloudwatch_log_group" "alert" {
  name = "cloudtrail-logs"
  retention_in_days  = 180
}
resource "aws_s3_bucket" "alert" {
   bucket = "lessen-dev-cloudtrail-logs"
}
resource "aws_s3_bucket_versioning" "alert" {
  bucket = aws_s3_bucket.alert.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "alert" {
  bucket = aws_s3_bucket.alert.id
  depends_on = [aws_s3_bucket.alert]
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}
resource "aws_s3_bucket_public_access_block" "alert" {
  bucket = aws_s3_bucket.alert.id
  depends_on = [aws_s3_bucket.alert]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "alert" {
  bucket = aws_s3_bucket.alert.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.alert.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.alert.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "sid0"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "cloudtrail-policy"
  role = aws_iam_role.cloudtrail_role.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action =  [
          "logs:PutLogEvents",
          "logs:CreateLogStream"

        ]
        Effect   = "Allow"
        Resource = "[aws_cloudwatch_log_group.alert.arn]"
      },
    ]

  })
}
resource "aws_cloudtrail" "alerts" {
  depends_on  = [aws_iam_role.cloudtrail_role]
  name        = "cloudtrail-global"
  enable_log_file_validation = "true"
  is_multi_region_trail    = "true"
  include_global_service_events = "true"
  s3_bucket_name  = "aws_s3_bucket.alert.id"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  cloud_watch_logs_group_arn   = aws_cloudwatch_log_group.alert.arn
}
resource "aws_guardduty_detector" "alert" {
  enable = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  datasources {
    s3_logs {
      enable = false
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
  }
}
resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "guarduty-findings-rule"
  description = "Event rule to trigger SNS notification on medium severity or greater GuardDuty finding"
  is_enabled  = "true"


  event_pattern = <<PATTERN
{
      "source": ["aws.guardduty"],
      "detail-type": ["GuardDuty Finding"],
      "detail": {
        "severity": [4,4.0,4.1,4.2,4.3,4.4,4.5,4.6,4.7,4.8,4.9,5,5.0,5.1,5.2,5.3,5.4,5.5,5.6,5.7,5.8,5.9,6,6.0,6.1,6.2,6.3,6.4,6.5,6.6,
          6.7,6.8,6.9,7,7.0,7.1,7.2,7.3,7.4,7.5,7.6,7.7,7.8,7.9,8,8.0,8.1,8.2,8.3,8.4,8.5,8.6,8.7,8.8,8.9]
       }
}
PATTERN
}
resource "aws_cloudwatch_event_target" "guardduty" {
  rule = aws_cloudwatch_event_rule.guardduty.name
  target_id = "Target0"
  arn = aws_sns_topic.this.arn
}
resource "aws_securityhub_account" "guardsecurityhub" {

}
resource "aws_cloudwatch_event_rule" "guardsecurityhub" {
  name        = "security-hub-imported-findings"
  description = "Event rule to trigger SNS notification on security hub imported findings"
  is_enabled  = "true"


  event_pattern = <<PATTERN
{
    "source": ["aws.securityhub"],
    "detail-type": ["Security Hub Findings - Imported"],
    "detail": {
      "findings": {
        "Severity": {
          "Label": ["HIGH", "CRITICAL"]
         }
       }
     }
}
PATTERN
}
resource "aws_cloudwatch_event_target" "guardsecurityhub" {
  rule = aws_cloudwatch_event_rule.guardsecurityhub.name
  target_id = "Target0"
  arn = aws_sns_topic.this.arn
}
