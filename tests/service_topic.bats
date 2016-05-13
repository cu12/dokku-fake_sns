#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:topic:add) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:add"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:remove) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:remove"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:add) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:add" not_existing_service
  assert_contains "${lines[*]}" "Please specify an SNS topic name"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:remove) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:remove" not_existing_service
  assert_contains "${lines[*]}" "Please specify an SNS topic name"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:list) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:list" not_existing_service
  assert_contains "${lines[*]}" "Fakesns service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:list) success when topics are listed" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:list" l
  assert_output "docker exec dokku.sns.l /usr/bin/env sh -c AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake AWS_DEFAULT_REGION=fake aws --endpoint-url http://localhost:9292 sns list-topics --output text"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:add) error when topic exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:add" l m
  assert_contains "${lines[*]}" "Fakesns service l topic already exist: m"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:add) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:add" l l
  assert_contains "${lines[*]}" "Fakesns topic added: l"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:remove) error when topic does not exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:remove" l l
  assert_contains "${lines[*]}" "Fakesns service l topic does not exist: l"
}

@test "($PLUGIN_COMMAND_PREFIX:topic:remove) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:topic:remove" l m
  assert_contains "${lines[*]}" "Fakesns topic removed: m"
}
