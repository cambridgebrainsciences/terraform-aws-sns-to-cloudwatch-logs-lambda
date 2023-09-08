# terraform-aws-sns-to-cloudwatch-logs-lambda

[![Latest Release](https://img.shields.io/github/release/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda.svg)](https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda) [![license](https://img.shields.io/github/license/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda.svg?colorB=2067b8)](https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda)

`terraform-aws-sns-to-cloudwatch-logs-lambda` is a Terraform module to provision a Lambda Function which routes SNS messages to CloudWatch Logs

> Exception: if using `var.aws_region` to specify deployment region, use `version = "2.0.1"`, until you can switch to provider aliases and [explicit provider passing](https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly).

## Terraform Module Features

This Module allows simple and rapid deployment

- Creates Lambda function, Lambda Layer, IAM Policies, Triggers, and Subscriptions
- Creates (or use existing) SNS Topic, CloudWatch Log Group and Log Group Stream
- Options:
  - Create CloudWatch Event to prevent Function hibernation
  - Set Log Group retention period
- Python function editable in repository and in Lambda UI
  - Python dependencies packages in Lambda Layers zip
- Optionally create custom Lambda Layer zip using [build-lambda-layer-python](https://github.com/robertpeteuil/build-lambda-layer-python)
  - Enables adding/changing dependencies
  - Enables compiling for different version of Python
- **Breaking Changes** in `3.0.0` - required to enable new Terraform 0.13 module arguments `for_each`, `count`, and `depends_on`
  - The module's internal AWS `provider` block has been removed
  - `var.aws_region` has been removed and can't be used to set a target region
  - By default, modules inherit the `region` of the calling module's Provider
  - To specify alternate regions, use provider aliases and [expicit provider passing](https://www.terraform.io/docs/configuration/modules.html#passing-providers-explicitly)
  - Additional information on module considerations can be found in the docs for [Provider Configuration in Modules with 0.13](https://www.terraform.io/docs/configuration/modules.html#legacy-shared-modules-with-provider-configurations)

## SNS to CloudWatch Logs Features

This Lambda Function forwards subject & body of SNS messages to CloudWatch Log Group Stream

- Enhances the value of CloudWatch Logs by enabling easy entry creation from any service, function and script that can send SNS notifications
- Enables cloud-init, bootstraps and functions to easily write log entries to a centralized CloudWatch Log
- Simplifies troubleshooting of solutions with decentralized logic
  - scripts and functions spread across instances, Lambda and services
- Easily add instrumentation to scripts: `aws sns publish --topic-arn $TOPIC_ARN --message $LOG_ENTRY`
  - Use with IAM instance policy requires `--region $AWS_REGION` parameter

## Usage

``` ruby
module "sns_logger" {
  source            = "robertpeteuil/sns-to-cloudwatch-logs-lambda/aws"
  version           = "3.0.1"     # Use with Terraform >= 0.12 (including 0.13)
  # version           = "1.0.1"   # Latest version for Terraform <= 0.11

  sns_topic_name    = "projectx-logging"
  log_group_name    = "projectx"
  log_stream_name   = "script-logs"
}
```

> NOTE: Make sure you are using [version pinning](https://www.terraform.io/docs/modules/usage.html#module-versions) to avoid unexpected changes when the module is updated.

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| sns_topic_name | Name of SNS Topic to be logged by Gateway | string | - | yes |
| log_group_name | Name of CloudWatch Log Group | string | - | yes |
| log_stream_name | Name of CloudWatch Log Stream | string | - | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create_sns_topic | Create new SNS topic | string | `true` | no |
| create_log_group | Create new log group | string | `true` | no |
| create_log_stream | Create new log stream | string | `true` | no |
| log_group_retention_days | Log Group retention (days) | string | `0` (forever) | no |
| lambda_func_name | Name for Lambda Function | string | dynamically calculated | no |
| lambda_description | Lambda Function Description | string | `Route SNS messages to CloudWatch Logs` | no |
| lambda_tags | Mapping of Tags to assign to Lambda function | map | `{}` | no |
| lambda_publish_func | Publish Lambda Function | string | `false` | no |
| lambda_runtime | Lambda runtime for Function | string | `python3.8` | no |
| lambda_timeout | Function time-out (seconds) | string | `3` | no |
| lambda_mem_size | Function RAM assigned (MB) | string | `128` | no |
| create_warmer_event | Create CloudWatch trigger event to prevent hibernation | string | `false` | no |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.31 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.31 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.sns_logged_item_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.sns_logged_item_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_role.lambda_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_cloudwatch_logs_polcy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.sns_cloudwatch_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.logging_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.sns_cloudwatchlog_multi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.warmer_multi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.sns_log_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.lambda_function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_cloudwatch_log_group.sns_logged_item_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.lambda_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cloudwatch_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_sns_topic.sns_log_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Boolean flag that determines if log group, 'log\_group\_name' is created.  If 'false' it uses an existing group of that name. | `bool` | `true` | no |
| <a name="input_create_log_stream"></a> [create\_log\_stream](#input\_create\_log\_stream) | Boolean flag that determines if log stream, 'log\_stream\_name' is created. If 'false' it uses an existing stream of that name. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Boolean flag that determines if SNS topic, 'sns\_topic\_name' is created. If 'false' it uses an existing topic of that name. | `bool` | `true` | no |
| <a name="input_create_warmer_event"></a> [create\_warmer\_event](#input\_create\_warmer\_event) | Boolean flag that determines if a CloudWatch Trigger event is created to prevent Lambda function from suspending. | `bool` | `false` | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description to assign to Lambda Function. | `string` | `""` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name to assign to Lambda Function. | `string` | `"SNStoCloudWatchLogs"` | no |
| <a name="input_lambda_function_path"></a> [lambda\_function\_path](#input\_lambda\_function\_path) | Custom AWS Lambda Function path | `string` | `""` | no |
| <a name="input_lambda_layer_arn"></a> [lambda\_layer\_arn](#input\_lambda\_layer\_arn) | Existing layer for AWS Lambda Function | `string` | `""` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Amount of RAM (in MB) assigned to the function. The default (and minimum) is 128MB, and the maximum is 3008MB. | `number` | `128` | no |
| <a name="input_lambda_publish_func"></a> [lambda\_publish\_func](#input\_lambda\_publish\_func) | Boolean flag that determines if Lambda function is published as a version. | `bool` | `false` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda runtime to use for the function. | `string` | `"python3.8"` | no |
| <a name="input_lambda_tags"></a> [lambda\_tags](#input\_lambda\_tags) | A mapping of tags to assign to Lambda Function. | `map` | `{}` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Number of seconds that the function can run before timing out. The AWS default is 3s and the maximum runtime is 5m | `number` | `3` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of CloudWatch Log Group created or used (if previously created). | `string` | n/a | yes |
| <a name="input_log_group_retention_days"></a> [log\_group\_retention\_days](#input\_log\_group\_retention\_days) | Number of days to retain data in the log group (0 = always retain). | `number` | `0` | no |
| <a name="input_log_stream_name"></a> [log\_stream\_name](#input\_log\_stream\_name) | Name of CloudWatch Log Stream created or used (if previously created).  If using an existing stream it must exist in the Log group specified in 'log\_group\_name'. | `string` | n/a | yes |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of SNS Topic logging to CloudWatch Log. | `string` | n/a | yes |
| <a name="input_use_existing_layer"></a> [use\_existing\_layer](#input\_use\_existing\_layer) | Re-use existing AWS Lambda Layer | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_arn"></a> [cloudwatch\_event\_rule\_arn](#output\_cloudwatch\_event\_rule\_arn) | ARN of CloudWatch Trigger Event created to prevent hibernation. |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN of created Lambda Function. |
| <a name="output_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#output\_lambda\_iam\_role\_arn) | Lambda IAM Role ARN. |
| <a name="output_lambda_iam_role_id"></a> [lambda\_iam\_role\_id](#output\_lambda\_iam\_role\_id) | Lambda IAM Role ID. |
| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | The date Lambda Function was last modified. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | Name assigned to Lambda Function. |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of Lambda Function. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of CloudWatch Log Group. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of CloudWatch Log Group. |
| <a name="output_log_stream_arn"></a> [log\_stream\_arn](#output\_log\_stream\_arn) | ARN of CloudWatch Log Stream. |
| <a name="output_log_stream_name"></a> [log\_stream\_name](#output\_log\_stream\_name) | Name of CloudWatch Log Stream. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of SNS Topic logging to CloudWatch Log. |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | Name of SNS Topic logging to CloudWatch Log. |
<!-- END_TF_DOCS -->
