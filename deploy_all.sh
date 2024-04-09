#!/bin/bash

for package_dir in ./packages/*/; do
  package_name=$(basename "$package_dir")
  deploy_dir="$package_dir/deploy"

  cd "$deploy_dir"

  npm install
  npm run build
  npm test
  
  chmod +x deploy.sh
  ./deploy.sh $package_name $TRAVIS_BRANCH $TRAVIS_COMMIT_MESSAGE
  cd ../../
done
