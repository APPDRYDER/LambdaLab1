#!/bin/bash
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
# Requires: jq (brew install jq)
#
#

##############################################################
#
_awsLambdaCreateFunction() {
  # Create a AWS Lambda Function
  _validateEnvironmentVars "AWS Create Lambda Function" \
    "AWS_LAMBDA_ROLE_NAME" "AWS_LAMBDA_FUNCTION_NAME" "AWS_LAMBDA_RUNTIME" "AWS_LAMBDA_HANDLER" "AWS_LAMBDA_ZIP_FILE"

  AWS_ROLE_POLICY_DOC_FILE="AWSLambdaBasicExecutionRole.json"

  # Create the AWS Role Policy Document File
  echo '{ "Version": "2012-10-17",
          "Statement": [ {
              "Action": "sts:AssumeRole",
              "Effect": "Allow",
              "Principal": { "Service": "lambda.amazonaws.com" } } ] }' > $AWS_ROLE_POLICY_DOC_FILE

  # Create the role for lambda functions
  aws iam create-role --role-name $AWS_LAMBDA_ROLE_NAME --assume-role-policy-document "file://$AWS_ROLE_POLICY_DOC_FILE"
  sleep 15 # Allow time for role to create

  # Get the role ARN, need to wait for role to create
  AWS_ROLE_ARN=""
  while [ "$AWS_ROLE_ARN" == "" ]; do
    echo "Waiting for role to create: $AWS_LAMBDA_ROLE_NAME"
    sleep 5
    AWS_ROLE_ARN=`aws iam get-role --role-name $AWS_LAMBDA_ROLE_NAME | jq -r '.Role | .Arn'`
  done
  echo "Role created: $AWS_LAMBDA_ROLE_NAME ARN $AWS_ROLE_ARN"

  # List functions: name, runtime, handler
  echo "Current functions"
  aws lambda list-functions | jq -r '[.Functions[] | {FunctionName, Runtime, Handler}  ]'

  # Create the lambda functions against the role
  aws lambda create-function \
    --function-name $AWS_LAMBDA_FUNCTION_NAME \
    --runtime $AWS_LAMBDA_RUNTIME \
    --role $AWS_ROLE_ARN \
    --timeout 30 \
    --publish \
    --handler $AWS_LAMBDA_HANDLER \
    --zip-file "fileb://$AWS_LAMBDA_ZIP_FILE"

  # Get the function ARN
  AWS_FUNCTION_ARN=`aws lambda get-function --function-name $AWS_LAMBDA_FUNCTION_NAME | jq -r '.Configuration | .FunctionArn'`

  echo "Function Created: $AWS_LAMBDA_FUNCTION_NAME ARN: $AWS_FUNCTION_ARN"
  aws lambda list-functions | jq -r '[.Functions[] | {FunctionName, Runtime, Handler}  ]'
} # _awsCreateFunction


##############################################################
#
_awsLambdaConfigureAppDynamics() {
  # Configure the AWS Lambda function with AppDynamics parameters
  _validateEnvironmentVars "AWS Configure AppDynamics" \
    "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY" "APPDYNAMICS_APPLICATION_NAME" \
    "APPDYNAMICS_CONTROLLER_HOST_NAME" "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_SERVERLESS_API_ENDPOINT" \
    "APPDYNAMICS_LOG_LEVEL" "APPDYNAMICS_TIER_NAME"

  # Note the transaction from Lambda enviroment var to AppD environment var
  PARAMS="{\"Variables\":
              {
                \"APPDYNAMICS_ACCOUNT_NAME\":\"$APPDYNAMICS_AGENT_ACCOUNT_NAME\",
                \"APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY\":\"$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY\",
                \"APPDYNAMICS_CONTROLLER_HOST\":\"$APPDYNAMICS_CONTROLLER_HOST_NAME\",
                \"APPDYNAMICS_CONTROLLER_PORT\":\"$APPDYNAMICS_CONTROLLER_PORT\",
                \"APPDYNAMICS_SERVERLESS_API_ENDPOINT\":\"$APPDYNAMICS_SERVERLESS_API_ENDPOINT\",
                \"APPDYNAMICS_APPLICATION_NAME\":\"$APPDYNAMICS_APPLICATION_NAME\",
                \"APPDYNAMICS_NODE_NAME\":\"$APPDYNAMICS_NODE_NAME\",
                \"APPDYNAMICS_LOG_LEVEL\":\"$APPDYNAMICS_LOG_LEVEL\"
             }
          }"
  aws lambda update-function-configuration --function-name $AWS_LAMBDA_FUNCTION_NAME --region $AWS_REGION --environment "$PARAMS"
} # _awsLambdaConfigureAppDynamics


_awsCreateRestAPI() {
  # Create an AWS API Gateway API that invoeks the Lambda Function
  _validateEnvironmentVars "AWS Configure AWS API Gateway" \
    "AWS_API_NAME" "AWS_REGION" "AWS_API_PATH" "AWS_API_PATH" "AWS_API_STAGE" "AWS_LAMBDA_FUNCTION_NAME"

  # Create API gateway
  aws apigateway create-rest-api --name $AWS_API_NAME --region $AWS_REGION

  # Get the Rest API ID and the API Parent / Root ID
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  AWS_API_PARENT_ID=`aws apigateway get-resources --rest-api-id $AWS_REST_API_ID | jq -r '.items[] | .id'`
  echo "AWS API ID $AWS_REST_API_ID PARENT ID $AWS_API_PARENT_ID"

  # create-resource to create an API Gateway Resource of $AWS_API_PATH
  aws apigateway create-resource --rest-api-id $AWS_REST_API_ID --region $AWS_REGION \
    --parent-id $AWS_API_PARENT_ID --path-part $AWS_API_PATH

  # Get the API Resurce ID
  AWS_API_RESOURCE_ID=`aws apigateway get-resources --rest-api-id $AWS_REST_API_ID | jq --arg SEARCH_STR $AWS_API_PATH  -r '.items[] | select(.path | test($SEARCH_STR)) | .id'`
  aws apigateway put-method --rest-api-id $AWS_REST_API_ID --resource-id $AWS_API_RESOURCE_ID \
    --http-method $AWS_API_HTTP_METHOD --authorization-type "NONE"

  # Get the Functions ARN
  AWS_FN_ARN=`aws lambda list-functions | jq --arg SEARCH_STR $AWS_LAMBDA_FUNCTION_NAME -r '.Functions[] | select(.FunctionName | test($SEARCH_STR)) |  .FunctionArn'`
  echo "Lambda function $AWS_LAMBDA_FUNCTION_NAME ARN $AWS_FN_ARN"

  # set the POST method response to JSON. This is the response type that your API method returns
  aws apigateway put-method-response --rest-api-id $AWS_REST_API_ID --resource-id $AWS_API_RESOURCE_ID \
    --http-method $AWS_API_HTTP_METHOD \
    --status-code 200 --response-models '{"application/json":"Empty"}'
    #"application/json=Empty"

  # Set the Lambda function as the integration point for the POST method
  aws apigateway put-integration --rest-api-id $AWS_REST_API_ID --resource-id $AWS_API_RESOURCE_ID --http-method POST --type AWS \
    --integration-http-method POST --uri "arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/$AWS_FN_ARN/invocations"

  # Set the POST method integration response to JSON. This is the response type that Lambda function returns
  aws apigateway put-integration-response --rest-api-id $AWS_REST_API_ID --resource-id $AWS_API_RESOURCE_ID \
    --http-method $AWS_API_HTTP_METHOD \
    --status-code 200 --response-templates '{"application/json":""}'
    # 'application/json=""'

  # Deploy the API to a stage called $AWS_API_STAGE (eg PROD)
  aws apigateway create-deployment --rest-api-id $AWS_REST_API_ID --stage-name $AWS_API_STAGE

  # Remove previous policy statement IDs - Ignore errors
  echo "Ignore Errors............."
  aws lambda remove-permission --function-name $AWS_LAMBDA_FUNCTION_NAME --statement-id "apigateway-s1-"$AWS_LAMBDA_FUNCTION_NAME
  aws lambda remove-permission --function-name $AWS_LAMBDA_FUNCTION_NAME --statement-id "apigateway-s2-"$AWS_LAMBDA_FUNCTION_NAME

  # Grant the AWS API Gateway service principal (apigateway.amazonaws.com) permissions to invoke  Lambda function (LambdaFunctionOverHttps)
  aws lambda add-permission --function-name $AWS_LAMBDA_FUNCTION_NAME \
    --statement-id "apigateway-s1-"$AWS_LAMBDA_FUNCTION_NAME \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:$AWS_REGION:$AWS_ACCOUNT_ID:$AWS_REST_API_ID/*/$AWS_API_HTTP_METHOD/$AWS_API_PATH"

  # Grant to deployed API permissions to invoke the Lambda function
  aws lambda add-permission --function-name $AWS_LAMBDA_FUNCTION_NAME \
    --statement-id "apigateway-s2-"$AWS_LAMBDA_FUNCTION_NAME \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:$AWS_REGION:$AWS_ACCOUNT_ID:$AWS_REST_API_ID/$AWS_API_STAGE/$AWS_API_HTTP_METHOD/$AWS_API_PATH"
}

_awsTestPostApiCurl() {
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  curl -X POST  \
       -d "$APPD_POST_DATA" \
       -H "x-api-key: $API_KEY" \
       -H "Content-Type: application/json" \
       "https://$AWS_REST_API_ID.execute-api.$AWS_REGION.amazonaws.com/$AWS_API_STAGE/$AWS_API_PATH"
}

_awsTestPostApiCurlError() {
   # Trigger the Lambda function to throw an Exception
  INTERATIONS_N=${1:-1}
  INTERVAL_SEC=${2:-1}
  POST_DATA='{ "error": "trigger an error"}'
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  for i in $(seq $INTERATIONS_N )
  do
    curl -X POST  \
         -d "$POST_DATA" \
         -H "x-api-key: $API_KEY" \
         -H "Content-Type: application/json" \
         "https://$AWS_REST_API_ID.execute-api.$AWS_REGION.amazonaws.com/$AWS_API_STAGE/$AWS_API_PATH"
    sleep $INTERVAL_SEC
  done
}
