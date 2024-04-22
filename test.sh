#!/bin/bash

set -e

branch=$1
commit=$2

failure=false

handle_error() {
  local line_number=$1
  local error_message=$2
  local exit_code=$?
  local command_output="$BASH_COMMAND"
  echo "Error: $error_message at line $line_number. Command: $command_output. Exit code: $exit_code" >&2
  # Establecer la bandera de fallo y cancelar el despliegue
  failure=true
}

trap 'handle_error "$LINENO" "Error deploying function: $function_name"' ERR

echo "Verifying deployment conditions"
if [[ "$(./deploy/can_deploy.sh $branch $commit)" != "1" ]]; then
  echo "Deployment conditions not met. Skipping deployment."
  exit 1
fi

deploy_function() {
  local package_name=$1
  echo "Start process to deploy cloud function ${package_name}"
  cd "./packages/$package_name"
  chmod +x ./deploy/deploy.sh
  echo "Deploying cloud function ${package_name}"
  ./deploy/deploy.sh "$package_name" || { handle_error "$LINENO" "Error deploying function: $package_name"; }
  cd ../../
}

# Desplegar cada función en paralelo
for package_dir in ./packages/*/; do
  deploy_function $(basename "$package_dir") &
done
wait

# Verificar si hubo algún error durante el despliegue
if [ "$failure" = true ]; then
  echo "One or more functions failed to deploy. Cancelling pipeline."
  exit 1
fi

echo "All functions deployed successfully"
exit 0
