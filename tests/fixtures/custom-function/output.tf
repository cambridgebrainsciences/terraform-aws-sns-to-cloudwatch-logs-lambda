# ----------------------------------------------------------------
# AWS SNS TO CLOUDWATCH LOGS LAMBDA GATEWAY - OUTPUTS
# ----------------------------------------------------------------

output "lambda_name" {
  description = "Name assigned to Lambda Function."
  value       = module.function.lambda_name
}

output "lambda_arn" {
  description = "ARN of created Lambda Function."
  value       = module.function.lambda_arn
}

output "lambda_version" {
  description = "Latest published version of Lambda Function."
  value       = module.function.lambda_version
}

output "lambda_last_modified" {
  description = "The date Lambda Function was last modified."
  value       = module.function.lambda_last_modified
}

output "lambda_iam_role_id" {
  description = "Lambda IAM Role ID."
  value       = module.function.lambda_iam_role_id
}

output "lambda_iam_role_arn" {
  description = "Lambda IAM Role ARN."
  value       = module.function.lambda_iam_role_arn
}

output "sns_topic_name" {
  description = "Name of SNS Topic logging to CloudWatch Log."
  value       = module.function.sns_topic_name
}

output "sns_topic_arn" {
  description = "ARN of SNS Topic logging to CloudWatch Log."
  value       = module.function.sns_topic_arn
}

output "log_group_name" {
  description = "Name of CloudWatch Log Group."
  value       = module.function.log_group_name
}

output "log_group_arn" {
  description = "ARN of CloudWatch Log Group."
  value       = module.function.log_group_arn
}

output "log_stream_name" {
  description = "Name of CloudWatch Log Stream."
  value       = module.function.log_stream_name
}

output "log_stream_arn" {
  description = "ARN of CloudWatch Log Stream."
  value       = module.function.log_stream_arn
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of CloudWatch Trigger Event created to prevent hibernation."
  value       = module.function.cloudwatch_event_rule_arn
}
