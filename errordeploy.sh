#!/bin/bash

set -e  # Salir inmediatamente si alguna instrucción falla

branch=$1
commit=$2

handle_error() {
  local line_number=$1
  local error_message=$2
  local exit_code=$?
  local command_output="$BASH_COMMAND"
  echo "Error: $error_message at line $line_number. Command: $command_output. Exit code: $exit_code" >&2
  exit 1
}

trap 'handle_error "$LINENO" "Error deploying function: $function_name"' ERR

# Función para capturar el PID del proceso de implementación
capture_pid() {
  local pid=$1
  pids+=("$pid")
}

# Array para almacenar los PID de los procesos de implementación
declare -a pids

for package_dir in ./packages/*/; do
  echo "Iniciando proceso para desplegar la función en la nube: ${package_dir}"
  package_name=$(basename "$package_dir")

  (  # Inicia un subshell para capturar errores en el despliegue de cada Cloud Function
    cd "$package_dir"
    chmod +x ./deploy/deploy.sh
    echo "Desplegando la función en la nube: ${package_name}"
    ./deploy/deploy.sh "$package_name"
  ) &  # Ejecuta en segundo plano
  capture_pid $!  # Captura el PID del proceso de implementación
  cd ../../
done

# Esperar hasta que alguno de los procesos secundarios termine
echo "Esperando a que algún proceso finalice..."
for deployment_pid in "${pids[@]}"; do
  wait $deployment_pid
  deployment_exit_code=$?

  if [ $deployment_exit_code -ne 0 ]; then
    echo "Error: Despliegue fallido para la Cloud Function ${package_dir}."
    exit 1  # Termina el script principal con un código de error
  fi
done

echo "Todos los despliegues de funciones en la nube se completaron exitosamente."
exit 0
