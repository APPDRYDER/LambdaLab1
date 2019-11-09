#!/bin/bash
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
#
# Requries: jq
#
cmd=${1:-"unknown"}



#h ttps://grb950ea62.execute-api.us-west-1.amazonaws.com/PROD
# https://5346onqbkg.execute-api.us-west-1.amazonaws.com/PROD/TEST2

POST_DATA='{ "firstName": "David", "lastName": "Ryder" }'

# Bash Utility Functions
. bash-functions.sh
. aws-functions.sh


_awsApi() {
  API_METHOD=$1
  curl -X POST  \
       -d "$POST_DATA" \
       -H "x-api-key: $API_KEY" \
       -H "Content-Type: application/json" \
       "https://$API_ID.execute-api.$API_REGION.amazonaws.com/$API_STAGE/$API_METHOD"
}


if [ $cmd == "createFunction" ]; then
  _awsCreateFunction

elif [ $cmd == "listFunctions" ]; then
  aws lambda list-functions | jq -r '[.Functions[] | {FunctionName, Runtime, Handler, FunctionArn}  ]'

elif [ $cmd == "invokeFunction" ]; then
   aws lambda invoke --function-name $AWS_LAMBDA_FUNCTION_NAME --payload '{"firstName":"David","lastName":"Ryder"}' /dev/stdout

elif [ $cmd == "updateFunctionCode" ]; then
  aws lambda update-function-code --function-name $AWS_LAMBDA_FUNCTION_NAME --zip-file $AWS_LAMBDA_ZIP_FILE

elif [ $cmd == "deleteFunction" ]; then
  aws lambda delete-function --function-name $AWS_LAMBDA_FUNCTION_NAME

elif [ $cmd == "configureAppDynamics" ]; then
  _awsLambdaConfigureAppDynamics

elif [ $cmd == "createRestApi" ]; then
  _awsCreateRestAPI

elif [ $cmd == "listRestApi" ]; then
  aws apigateway get-rest-apis

elif [ $cmd == "deleteRestApi" ]; then
  aws apigateway get-rest-apis
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  echo "Deleting $AWS_API_NAME ID: $AWS_REST_API_ID"
  aws apigateway delete-rest-api --rest-api-id $AWS_REST_API_ID
  aws apigateway get-rest-apis

elif [ $cmd == "p1" ]; then
echo "p1"

#arn:aws:lambda:us-west-1:167766966001:function:TEST1
elif [ $cmd == "test1" ]; then
  _awsApi "TEST1"

elif [ $cmd == "test2" ]; then
  # API Gateway Keys and Access
  API_ID="hrb950ea62"
  API_REGION="us-west-1"
  API_KEY="zT8n9fuqt22f0zvAKMqqx336xEnqHvDO1DbOgaN6"
  API_STAGE="PROD"
  _awsApi "TEST2"

elif [ $cmd == "run" ]; then
  ITERATIONS=1000
  for I in $(seq 0 $((ITERATIONS))); do
    _awsApi "TEST1"
    sleep 30
    _awsApi "TEST2"
    sleep 30
  done

elif [ $CMD == "testAwsApi" ]; then
  METHOD=$2
  curl -G "localhost:18081/test/API" --data-urlencode "method=$METHOD"


else
  echo "Command unknown: "$cmd
  echo "Commands: "
  echo "  createFunction"
  echo "  listFunctions"
  echo "  invokeFunction"
  echo "  updateFunctionCode"
  echo "  deleteFunction"
  echo "  configureAppDynamics"
  echo "  createRestApi"
  echo "  listRestApi"
  echo "  deleteRestApi"

fi

echo ""
