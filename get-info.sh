#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "service_account_token_name=\(.service_account_token_name) cluster=\(.cluster) zone=\(.zone) namespace=\(.namespace) project=\(.project)"')"

export KUBECONFIG=/tmp/kubeconfig

gcloud container clusters get-credentials $cluster --zone $zone --project $project
TOKEN=$(kubectl --kubeconfig $KUBECONFIG get secret $service_account_token_name -n kube-system -o jsonpath='{.data.token}' | base64 -d)

CONTEXT=$(kubectl --kubeconfig $KUBECONFIG config current-context)
kubectl --kubeconfig $KUBECONFIG config set-credentials ${CONTEXT}-token --token $TOKEN >/dev/null
kubectl --kubeconfig $KUBECONFIG config set-context $CONTEXT --user ${CONTEXT}-token >/dev/null
kubectl --kubeconfig $KUBECONFIG config unset users.$CONTEXT >/dev/null

KUBE_CONFIG_CONTENT=$(cat $KUBECONFIG | base64)

rm -rf $KUBECONFIG

jq -n --arg TOKEN "$TOKEN" --arg KUBE_CONFIG_CONTENT "$KUBE_CONFIG_CONTENT" '{"token":$TOKEN,"kube_config":$KUBE_CONFIG_CONTENT}'
