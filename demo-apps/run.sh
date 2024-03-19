#!/bin/bash

ACCOUNT_ID=`aws sts get-caller-identity --profile global| jq .Account -r`
sh ./hello/dockerbuild.sh $ACCOUNT_ID $AWS_DEFAULT_REGION "grafana-demo-hello"
sh ./world/dockerbuild.sh $ACCOUNT_ID $AWS_DEFAULT_REGION "grafana-demo-world"