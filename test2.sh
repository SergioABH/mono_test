#!/bin/bash

set -e

function_name=$1

handle_error() {
  local line_number=$1
  local error_message=$2
  local exit_code=$?
  local command_output="$BASH_COMMAND"
  local deploy_output=$(gcloud beta functions describe "$function_name")
  echo "Error: $error_message at line $line_number. Command: $command_output. Deployment Output: $deploy_output. Exit code: $exit_code" >&2
  exit 1
}

trap 'handle_error "$LINENO" "Error deploying function: $function_name"' ERR

# Desplegar la función
gcloud --quiet beta functions deploy "$function_name" \
  --runtime nodejs10 \
  --trigger-event providers/cloud.firestore/eventTypes/document.write \
  --trigger-resource "projects/${!GCP_PROJECT_ID}/databases/(default)/documents/{collection}/chats/{provider}/{conversationId}"

# Verificar si la función se desplegó correctamente
if gcloud beta functions describe "$function_name" --format='value(status)' | grep -q "READY"; then
  echo "Cloud function ${function_name} deployed successfully"
else
  handle_error "$LINENO" "Error deploying function: $function_name. Function not ready."
fi

exit 0
