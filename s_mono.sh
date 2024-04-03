#!/bin/bash

# Function directories
functions=$(find . -mindepth 1 -maxdepth 1 -type d)

for function in $functions; do
  # Check if the directory contains a .travis file
  if [[ -f "$function/.travis.yml" ]]; then
    echo "Deploying $function..."
    (
      cd "$function"
      # Execute the existing .travis.yml for deployment
      travis build
    ) &
  fi
done

# Wait for all deployments to finish
wait

echo "All Cloud Functions deployed successfully!"
