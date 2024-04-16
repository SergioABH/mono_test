#!/bin/bash

set -e

function_name=$1

handle_error() {
  local line_number=$1
  local error_message=$2
  local exit_code=$?
  local command_output="$BASH_COMMAND"  # Use BASH_COMMAND for the actual command
  echo "Error: $error_message at line $line_number. Command: $command_output. Exit code: $exit_code" >&2
  exit 1
}

trap 'handle_error "$LINENO" "Error deploying function: $function_name"' ERR

gcloud --quiet beta functions deploy "$function_name" \
    --runtime nodejs10 \
    --trigger-event providers/cloud.firestore/eventTypes/document.write \
    --trigger-resource "projects/${!GCP_PROJECT_ID}/databases/(default)/documents/{collection}/registry/campaign/{campaignId}/strategy/{strategyId}/task/{taskId}"

exit 0
