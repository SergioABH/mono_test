#!/bin/bash

set -e

# Obtener los argumentos pasados desde el pipeline
branch=$1
commit_message=$2

handle_error() {
  local line_number=$1
  local error_message=$2
  echo "Error: $error_message at line $line_number" >&2
  exit 1
}

trap 'handle_error "$LINENO" "$?"' ERR

# Verificar si las condiciones de despliegue se cumplen utilizando can_deploy.sh
if [[ "$(./deploy/can_deploy.sh "$branch" "$commit_message")" != "1" ]]; then
  echo "Deployment conditions not met. Skipping deployment."
  exit 0
fi

# Si las condiciones de despliegue se cumplen, continuar con el despliegue
for package_dir in ./packages/*/; do
  echo "Start process to deploy cloud function ${package_dir}"
  package_name=$(basename "$package_dir")

  cd "$package_dir"
  
  chmod +x ./deploy/deploy.sh
  echo "Deploying cloud function ${package_name}"
  ./deploy/deploy.sh $package_name
  
  cd ..
done

exit 0
