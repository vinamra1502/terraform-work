# aws-pipeline-alerts-lambda

This lambda listens for CodePipeline EventBridge events, enriches the data with information from GitHub, and publishes the event to the #aws-pipeline-alerts slack channel.

## AWS Infrastructure

In Monitoring.ts, there is a `createPipelineAlertsLambda()` function that handles creating the AWS resources required for this integration to work.  
It defines the Lambda function, the IAM role it executes under, and the EventBridge rule that will trigger the lambda.  
For documentation about EventBridge rules, see the following links:

- [Example of how value matching works for EventBridge rules](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html#eb-filtering-data-types)
- [Example of an event that's emitted when a CodePipeline Action fails](https://docs.aws.amazon.com/codepipeline/latest/userguide/detect-state-changes-cloudwatch-events.html#detect-state-events-action-failed)

## Logging

The CloudWatch log group that the lambda logs to is `/aws/lambda/aws-pipeline-alerts-lambda`.

## Slack Configuration

AWS ChatBot does not support custom messages sent from a lambda function.  
In order to work around this, we had to publish to Slack directly via a webhook instead of using ChatBot.  
The Slack app I created can be found here: https://api.slack.com/apps/A02Q5P5SZHC/general  
I enabled incoming webhooks so that we can publish messages to it from the lambda.  
Note that the URL for the webhook contains secrets, so I stored the URL safely in Parameter Store in the dev environment in the `/kms-opus-one-dev/AWS_PIPELINE_ALERTS_SLACK_WEBHOOK_URL` parameter.  
I also enabled OAuth User tokens and added the `users:read` and `users:read.email` scopes so that we can look up slack users by email address.  
The OAuth token value is stored in Parameter Store in the dev environment in the `/kms-opus-one-dev/AWS_PIPELINE_ALERTS_SLACK_USER_TOKEN`
