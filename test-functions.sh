#!/bin/bash
#
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
INTERVAL_SEC=${2:-"15"}
INTERATIONS_N=${3:-"480"}
MESSAGE_STR=${4:-'{"firstName":"David", "lastName":"Ryder"}'}

_testJavaAppLoadGen1() {
  # Invoke the the JavaApp API test/API with AWS API Gateway url

  # ID of the API Gateway REST API
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  echo "Rest API [$AWS_API_NAME $AWS_REST_API_ID] "

  # Host Port and API for JavaApp
  HOST="localhost"
  PORT="18081"
  API="/aws/API"

  # Test Java App is running
  V1=`curl -s $HOST:$PORT/aws/health`
  if [ "$V1" != "ok" ]; then
    echo "Java App on Host: $HOST Port: $PORT is not running"
    exit 1
  fi

  echo "Starting _testJavaAppLoadGen1"
  for i in $(seq $INTERATIONS_N )
  do
    echo "Calling: $HOST:$PORT$API $i"
    curl -G $HOST:$PORT$API \
      --data-urlencode "region=$AWS_REGION" \
      --data-urlencode "apiId=$AWS_REST_API_ID" \
      --data-urlencode "stage=$AWS_API_STAGE" \
      --data-urlencode "apiPath=$AWS_API_PATH" \
      --data-urlencode "apiKey=$AWS_API_KEY" \
      --data-urlencode "message=$MESSAGE_STR"
    sleep $INTERVAL_SEC
  done
  echo "Complete _testJavaAppLoadGen1"
}
