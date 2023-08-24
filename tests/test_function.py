import re

import pytest
import tftest
from moto.server import ThreadedMotoServer
import logging

LOGGER = logging.getLogger(__name__)


@pytest.fixture
def output(fixtures_dir):
    server = ThreadedMotoServer(ip_address="127.0.0.1", port=9999)
    server.start()
    tf = tftest.TerraformTest("basic", fixtures_dir)
    tf.init()
    tf.setup()
    tf.apply()
    yield tf.output()
    tf.destroy(**{"auto_approve": True})
    server.stop()


def test_apply(output):
    arn_regex = r"^arn:(?P<Partition>[^:\n]*):(?P<Service>[^:\n]*):(?P<Region>[^:\n]*):(?P<AccountID>[^:\n]*):(?P<Ignore>(?:[^\/\n]*\/[^\/\n]*)?(?P<ResourceType>[^:\/\n]*)[:\/])?(?P<Resource>.*)$"
    last_modified_regex = r"([1|2]\d{3})-((0[1-9])|(1[0-2]))-([0-2][1-9])"
    lambda_name = output["lambda_name"]
    lambda_arn = output["lambda_arn"]
    lambda_version = output["lambda_version"]
    lambda_last_modified = output["lambda_last_modified"]
    lambda_iam_role_id = output["lambda_iam_role_id"]
    lambda_iam_role_arn = output["lambda_iam_role_arn"]
    sns_topic_name = output["sns_topic_name"]
    sns_topic_arn = output["sns_topic_arn"]
    log_group_name = output["log_group_name"]
    log_group_arn = output["log_group_arn"]
    log_stream_name = output["log_stream_name"]
    log_stream_arn = output["log_stream_arn"]
    cloudwatch_event_rule_arn = output["cloudwatch_event_rule_arn"]
    assert len(lambda_name) > 18
    assert lambda_name.startswith("SNStoCloud")
    assert len(lambda_arn) > 80
    assert re.match(arn_regex, lambda_arn)
    assert re.match(r"[$A-Z]", lambda_version)
    assert len(lambda_version) >= 7
    assert len(lambda_last_modified) >= 19
    assert re.match(last_modified_regex, lambda_last_modified)
    assert len(lambda_iam_role_id) == 43
    assert lambda_iam_role_id.startswith("lambda-snstocloudwatchlogs")
    assert re.match(arn_regex, lambda_iam_role_arn)
    assert re.match(arn_regex, sns_topic_arn)
    assert re.match(arn_regex, log_group_arn)
    assert re.match(arn_regex, log_stream_arn)
    assert not re.match(arn_regex, cloudwatch_event_rule_arn)
    assert cloudwatch_event_rule_arn == ""
    assert len(sns_topic_name) == 16
    assert sns_topic_name.startswith("ses-")
    assert len(log_group_name) == 4
    assert log_group_name == "fake"
    assert len(log_stream_name) == 4
    assert log_stream_name == "fake"
