provider "aws" {
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  access_key                  = "fake"
  secret_key                  = "fake"
  region                      = "us-west-2"
  endpoints {
    apigateway     = "http://localhost:9999"
    cloudformation = "http://localhost:9999"
    cloudwatch     = "http://localhost:9999"
    dynamodb       = "http://localhost:9999"
    es             = "http://localhost:9999"
    iam            = "http://localhost:9999"
    kinesis        = "http://localhost:9999"
    lambda         = "http://localhost:9999"
    route53        = "http://localhost:9999"
    s3             = "http://localhost:9999"
    sns            = "http://localhost:9999"
    sqs            = "http://localhost:9999"
    ssm            = "http://localhost:9999"
    sts            = "http://localhost:9999"
    firehose       = "http://localhost:9999"
    redshift       = "http://localhost:9999"
    secretsmanager = "http://localhost:9999"
    ses            = "http://localhost:9999"
    stepfunctions  = "http://localhost:9999"
    cloudwatchlogs = "http://localhost:9999"
  }
}

module "function" {
  source          = "../../../"
  log_group_name  = "fake"
  log_stream_name = "fake"
  sns_topic_name  = "ses-notification"
}
