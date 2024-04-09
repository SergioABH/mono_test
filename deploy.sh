#!/bin/bash

function_name=$1
branch=$2
commit_message=$3

if ./deploy/can_deploy.sh $branch $commit_message == "1"; then
    gcloud --quiet beta functions deploy $function_name \
        --runtime nodejs10 \
        --trigger-event providers/cloud.firestore/eventTypes/document.write \
        --trigger-resource "projects/${!GCP_PROJECT_ID}/databases/(default)/documents/{collection}/registry/campaign/{campaignId}/strategy/{strategyId}/task/{taskId}"
else
    echo "Skipping deployment of $function_name."
fi
