#!/bin/bash
#
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#

# Load generator for the Java App
_testJavaAppLoadGen1() {
  # Invoke the the JavaApp API test/API with AWS API Gateway url
  INTERATIONS_N=1024
  INTERVAL_SEC=15

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
      --data-urlencode """message=$APPD_POST_DATA"""
    sleep $INTERVAL_SEC
  done
  echo "Complete _testJavaAppLoadGen1"
}

_awsTestPostApiJavaApp() {
  AWS_REST_API_ID=`aws apigateway get-rest-apis  | jq --arg SEARCH_STR $AWS_API_NAME -r '.items[] | select(.name | test($SEARCH_STR)) |  .id'`
  java -cp $JAVA_TEST_APP_JAR pkg1.AwsLambda $AWS_REGION $AWS_REST_API_ID $AWS_API_STAGE $AWS_API_PATH '""' "$APPD_POST_DATA"

}

_stopJavaApp() {
  _validateEnvironmentVars "Stop Java App" "JAVA_TEST_APP_JAR"
  # Stop
  echo "Stop running instance of $JAVA_TEST_APP_JAR"
  ps -ef | grep "$JAVA_TEST_APP_JAR" ; sleep 1
  pkill -f "$JAVA_TEST_APP_JAR" ; sleep 1
}


# Start the Java App with the AppDynamics Application Agent
_startJavaApp() {
  NODE_ID="1"

  _validateEnvironmentVars "Java App with AppDynmaics Java Agent" \
    "APPDYNAMICS_APPLICATION_AGENT_JAR_FILE" "APPDYNAMICS_APPLICATION_NAME" \
    "JAVA_TEST_APP_JAR" "JAVA_TEST_APP_TIER_NAME" "JAVA_TEST_APP_NODE_NAME"

  # Stop the current running instance
  _stopJavaApp

  # Class path and options
  export JAVA_OPTS=""
  if [ -e "$APPDYNAMICS_APPLICATION_AGENT_JAR_FILE" ]; then
    export JAVA_OPTS="$JAVA_OPTS -javaagent:$APPDYNAMICS_APPLICATION_AGENT_JAR_FILE "
  else
    echo ""
    echo "AppDynamics Java Agent not found (APPDYNAMICS_APPLICATION_AGENT_JAR_FILE): $APPDYNAMICS_APPLICATION_AGENT_JAR_FILE"
    echo "Check the environment variable APPDYNAMICS_APPLICATION_AGENT_JAR_FILE pointw to the file javaagent.jar"
    exit 0
  fi
  export JAVA_OPTS=$JAVA_OPTS"-Djava.security.egd=file:/dev/./urandom "
  export JAVA_OPTS=$JAVA_OPTS"-Dappdynamics.low.entropy=true "
  export JAVA_OPTS=$JAVA_OPTS"-Dallow.unsigned.sdk.extension.jars=true "
  export JAVA_OPTS=$JAVA_OPTS"-Dappdynamics.analytics.agent.url=$APPDYNAMICS_ANALYTICS_AGENT_URL "

  echo "JAVA_OPS [$JAVA_OPTS]"
  rm -rf nohup.out
  touch nohup.out

  # Assign a port number
  PARAM_NODE_PORT=$((18080 + NODE_ID)) #18081, 18082, .....

  # Override using -D options
  unset APPDYNAMICS_AGENT_TIER_NAME
  unset APPDYNAMICS_AGENT_NODE_NAME

  APPD_OPTIONS=""
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.applicationName=$APPDYNAMICS_APPLICATION_NAME "
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.tierName=$JAVA_TEST_APP_TIER_NAME "
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.nodeName=$JAVA_TEST_APP_NODE_NAME$NODE_ID"
  echo "Starting: Node: $NODE_ID on Port: $PARAM_NODE_PORT AppName: $APPDYNAMICS_APPLICATION_NAME"
  nohup java $JAVA_OPTS $APPD_OPTIONS -jar $JAVA_TEST_APP_JAR $PARAM_NODE_PORT &

  # Tail the log file for 60 seconds
  _tailLog 60 nohup.out
}

_test1() {
  echo "_test1 $1"
}
