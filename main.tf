locals {
  dynamic_description  = "Routes SNS topic '${var.sns_topic_name}' to CloudWatch group '${var.log_group_name}' and stream '${var.log_stream_name}'"
  layer_arn            = var.lambda_layer_arn != "" && var.use_existing_layer ? var.lambda_layer_arn : aws_lambda_layer_version.logging_base.0.arn
  lambda_function_path = var.lambda_function_path != "" ? var.lambda_function_path : "${path.module}/function/sns_cloudwatch_gw.py"

}

resource "aws_lambda_layer_version" "logging_base" {
  count            = var.use_existing_layer ? 0 : 1
  filename         = "${path.module}/base_${var.lambda_runtime}.zip"
  source_code_hash = filebase64sha256("${path.module}/base_${var.lambda_runtime}.zip")

  layer_name  = "sns-cloudwatch-base-${replace(var.lambda_runtime, ".", "")}"
  description = "python logging and watchtower libraries"

  compatible_runtimes = [var.lambda_runtime]
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = local.lambda_function_path
  output_path = "${path.module}/lambda.zip"
}

# create lambda using function only zip on top of base layer
resource "aws_lambda_function" "sns_cloudwatch_log" {
  layers = [local.layer_arn]

  function_name = "${var.lambda_function_name}-${var.sns_topic_name}"
  description   = length(var.lambda_description) > 0 ? var.lambda_description : local.dynamic_description

  filename         = "${path.module}/lambda.zip"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  publish = var.lambda_publish_func ? true : false
  role    = aws_iam_role.lambda_cloudwatch_logs.arn

  runtime     = var.lambda_runtime
  handler     = "sns_cloudwatch_gw.main"
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      log_group  = var.log_group_name
      log_stream = var.log_stream_name
    }
  }

  tags = var.lambda_tags
}

# -----------------------------------------------------------------
# SNS TOPIC
#   create new topic (if create_sns_topic set), else use existing topic
#   arn referenced by "lambda_permssion" and "aws_sns_topic_subscription"
# -----------------------------------------------------------------

# create if specified
resource "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 1 : 0
  name  = var.sns_topic_name
}

# retrieve topic if not created, arn referenced
data "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 0 : 1
  name  = var.sns_topic_name
}

# -----------------------------------------------------------------
# CLOUDWATCH LOG GROUP
#   create new log_group (if create_log_group set)
# -----------------------------------------------------------------

resource "aws_cloudwatch_log_group" "sns_logged_item_group" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name
  retention_in_days = var.log_group_retention_days
}

# retrieve log group if not created, arn included in outputs
data "aws_cloudwatch_log_group" "sns_logged_item_group" {
  count = var.create_log_group ? 0 : 1
  name  = var.log_group_name
}

# -----------------------------------------------------------------
# CLOUDWATCH LOG STREAM
#   created new log stream (if create_log_stream set)
# -----------------------------------------------------------------

# create stream in log_group previously created or specified
resource "aws_cloudwatch_log_stream" "sns_logged_item_stream" {
  count          = var.create_log_stream ? 1 : 0
  name           = var.log_stream_name
  log_group_name = var.create_log_group ? aws_cloudwatch_log_group.sns_logged_item_group[0].name : var.log_group_name
}

# -----------------------------------------------------------------
# SUBSCRIBE LAMBDA FUNCTION TO SNS TOPIC
# -----------------------------------------------------------------

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  protocol  = "lambda"
  endpoint  = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatch_log.qualified_arn : aws_lambda_function.sns_cloudwatch_log.arn
}

# -----------------------------------------------------------------
# ENABLE SNS TOPIC AS LAMBDA FUNCTION TRIGGER
# -----------------------------------------------------------------

# function published - "qualifier" set to function version
resource "aws_lambda_permission" "sns_cloudwatchlog_multi" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_cloudwatch_log.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  qualifier     = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatch_log.version : null
}

# -------------------------------------------------------------------------------------
# CREATE IAM ROLE AND POLICIES FOR LAMBDA FUNCTION
# -------------------------------------------------------------------------------------

# Create IAM role
resource "aws_iam_role" "lambda_cloudwatch_logs" {
  name               = "lambda-${lower(var.lambda_function_name)}-${var.sns_topic_name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_logs.json
}

# Add base Lambda Execution policy
resource "aws_iam_role_policy" "lambda_cloudwatch_logs_polcy" {
  name   = "lambda-${lower(var.lambda_function_name)}-policy-${var.sns_topic_name}"
  role   = aws_iam_role.lambda_cloudwatch_logs.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs_policy.json
}

# JSON POLICY - assume role
data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# JSON POLICY - base Lambda Execution policy
data "aws_iam_policy_document" "lambda_cloudwatch_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

# -----------------------------------------------------------------
# CREATE CLOUDWATCH EVENT TO PREVENT LAMBDA FUNCTION SUSPENSION
# -----------------------------------------------------------------

# create cloudwatch event to run every 15 minutes
resource "aws_cloudwatch_event_rule" "warmer" {
  count = var.create_warmer_event ? 1 : 0

  name                = "sns-logger-warmer-${var.sns_topic_name}"
  description         = "Keeps ${var.lambda_function_name} Warm"
  schedule_expression = "rate(15 minutes)"
}

# set event target as sns_to_cloudwatch_logs lambda function
resource "aws_cloudwatch_event_target" "warmer" {
  count = var.create_warmer_event ? 1 : 0

  # rule      = join("", aws_cloudwatch_event_rule.warmer.*.name)
  rule      = aws_cloudwatch_event_rule.warmer[0].name
  target_id = "Lambda"
  arn       = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatch_log.qualified_arn : aws_lambda_function.sns_cloudwatch_log.arn

  input = <<JSON
{
	"Records": [{
		"EventSource": "aws:events"
	}]
}
JSON
}

# -----------------------------------------------------------------
# ENABLE CLOUDWATCH EVENT AS LAMBDA FUNCTION TRIGGER
# -----------------------------------------------------------------

resource "aws_lambda_permission" "warmer_multi" {
  count = var.create_warmer_event ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_cloudwatch_log.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.warmer[0].arn
  qualifier     = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatch_log.version : null
}
