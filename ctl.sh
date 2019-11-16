#!/bin/bash
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
#
# Requries: jq (brew install jq)
#
cmd=${1:-"unknown"}
OS_TYPE=`uname -s`


# Bash, AWS and Java Aoo Test Utility Functions
. Scripts/bash-functions.sh
. Scripts/aws-functions.sh
. Scripts/test-functions.sh

# Commands
if [ $cmd == "createFunction" ]; then
  _awsLambdaCreateFunction

elif [ $cmd == "listFunctions" ]; then
  aws lambda list-functions | jq -r '[.Functions[] | {FunctionName, Runtime, Handler, FunctionArn}  ]'

elif [ $cmd == "invokeFunction" ]; then
   aws lambda invoke --function-name $AWS_LAMBDA_FUNCTION_NAME --payload "$APPD_POST_DATA" /dev/stdout

elif [ $cmd == "updateFunctionCode" ]; then
  aws lambda update-function-code --function-name $AWS_LAMBDA_FUNCTION_NAME --zip-file fileb://$AWS_LAMBDA_ZIP_FILE

elif [ $cmd == "updateFunctionHandler" ]; then
  HANDLER=${2:-"$AWS_LAMBDA_HANDLER"}
  aws lambda update-function-configuration --function-name $AWS_LAMBDA_FUNCTION_NAME --handler $HANDLER

elif [ $cmd == "deleteFunction" ]; then
  aws lambda delete-function --function-name $AWS_LAMBDA_FUNCTION_NAME
  # aws iam delete-role --role-name $AWS_LAMBDA_ROLE_NAME

elif [ $cmd == "configureAppDynamicsLambda" ]; then
  _awsLambdaConfigureAppDynamics

elif [ $cmd == "createRestApi" ]; then
  _awsCreateRestAPI

elif [ $cmd == "listRestApi" ]; then
  aws apigateway get-rest-apis | jq -r '.items[] | {name, id}'

elif [ $cmd == "deleteRestApi" ]; then
  aws apigateway get-rest-apis | jq -r '.items[] | {name, id}'
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  echo "Deleting $AWS_API_NAME ID: ($AWS_REST_API_ID)"
  aws apigateway delete-rest-api --rest-api-id $AWS_REST_API_ID
  aws apigateway get-rest-apis | jq -r '.items[] | {name, id}'

elif [ $cmd == "testRestApiCurl" ]; then
  # Test call to API Gateway and invoke Lamnda Function using curl
  _awsTestPostApiCurl

elif [ $cmd == "testRestApiJavaApp" ]; then
  # Test call to API Gateway using the Java App
  _awsTestPostApiJavaApp

elif [ $cmd == "startJavaApp" ]; then
  _startJavaApp

elif [ $cmd == "stopJavaApp" ]; then
  _stopJavaApp

elif [ $cmd == "loadGenJavaApp" ]; then
  _testJavaAppLoadGen1

elif [ $cmd == "installJq" ]; then
  if [ "$OS_TYPE" == "Darwin" ]; then
      brew install jq
  elif [ "$OS_TYPE" == "Linux" ]; then
      sudo apt-get install jq
  else
      echo "Unknown OS TYPE: $OS_TYPE"
  fi

elif [ $cmd == "installAwsCli" ]; then
  if [ "$OS_TYPE" == "Darwin" ]; then
    # https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    sudo /usr/local/bin/python awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    aws --version
  elif [ "$OS_TYPE" == "Linux" ]; then
    sudo apt-get install awscli
  else
    echo "Unknown OS TYPE: $OS_TYPE"
  fi

elif [ $cmd == "installMaven" ]; then
  # https://maven.apache.org/download.cgi
  _validateEnvironmentVars "Installing Apache Maven" \
    "MAVEN_APACHE_DOWNLOAD_MIRROR" "MAVEN_DOWNLOAD_FILE"
  DOWNLOAD_URL=http://$MAVEN_APACHE_DOWNLOAD_MIRROR/maven/maven-3/3.6.2/binaries/$MAVEN_DOWNLOAD_FILE
  echo "Downloading: $DOWNLOAD_URL"
  curl  $DOWNLOAD_URL --output $MAVEN_DOWNLOAD_FILE
  tar xf $MAVEN_DOWNLOAD_FILE
  MAVEN_PATH=`pwd`"/$MAVEN_BASE_FILE/bin"
  echo "set PATH to Maven"
  echo ' export MAVEN_PATH=`pwd`/$MAVEN_BASE_FILE/bin'
  echo ' export PATH=$MAVEN_PATH:$PATH'

elif [ $cmd == "buildLambda" ]; then
  MVN_BIN="$MAVEN_BASE_FILE/bin/mvn"
  $MVN_BIN -f LambdaFunction/pom.xml clean install -U
  $MVN_BIN -f LambdaFunction/pom.xml package shade:shade
  # Built LambdaFunction/target/LambdaFunction-0.0.1-SNAPSHOT.jar

elif [ $cmd == "buildJavaApp" ]; then
  MVN_BIN="$MAVEN_BASE_FILE/bin/mvn"
  $MVN_BIN -f JavaApp/pom.xml clean install -U
  $MVN_BIN -f JavaApp/pom.xml assembly:single
  # Built LambdaFunction/target/LambdaFunction-0.0.1-SNAPSHOT.jar

elif [ $cmd == "run" ]; then
  ITERATIONS=5
  for I in $(seq 0 $((ITERATIONS))); do
    _awsApi "TEST1"
    sleep 30
    _awsApi "TEST2"
    sleep 30
  done

else
  echo "Commands: "
  echo "  createFunction"
  echo "  listFunctions"
  echo "  invokeFunction"
  echo "  updateFunctionCode"
  echo "  deleteFunction"
  echo "  configureAppDynamicsLambda"
  echo "  createRestApi"
  echo "  listRestApi"
  echo "  deleteRestApi"
  echo "  testRestApiCurl"
  echo "  testRestApiJavaApp"
  echo "  startJavaApp"
  echo "  loadGenJavaApp"
  echo "  installJq"
  echo "  installAwsCli"
  echo "  installMaven"
  echo "  buildLambda"
  echo "  buildJavaApp"

fi

echo ""
