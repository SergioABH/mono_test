#!/bin/bash

set -e  # Exit immediately if any command exits with a non-zero status

function handle_error() {
  local line_number="$1"
  local error_message="$2"
  echo "Error: $error_message at line $line_number" >&2  # Write to standard error for logging consistency
  exit 1
}

trap 'handle_error "$LINENO" "$BASH_COMMAND"' ERR

function deploy_function() {
  local function_name="$1"

  gcloud --quiet beta functions deploy "$function_name" \
    --runtime nodejs10 \
    --trigger-event providers/cloud.firestore/eventTypes/document.write \
    --trigger-resource "projects/${!GCP_PROJECT_ID}/databases/(default)/documents/{collection}/registry/campaign/{campaignId}/strategy/{strategyId}/task/{taskId}" || {
      handle_error "$LINENO" "Error deploying function: $function_name"
    }
}

# Usage: deploy_function <function_name>
deploy_function "$function_name"  # Replace with your actual function name

exit 0  # Explicit exit with code 0 to indicate successful execution
