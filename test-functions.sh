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
      --data-urlencode "message=$APPD_POST_DATA"
    sleep $INTERVAL_SEC
  done
  echo "Complete _testJavaAppLoadGen1"
}

_startJavaApp() {
  NODE_ID="1"

  _validateEnvironmentVars "Run Java App with AppDynmaics Java Agent" \
    "APPDYNAMICS_APPLICATION_AGENT_JAR_FILE" "APPDYNAMICS_APPLICATION_NAME"

  # Class path and options
  export JAVA_OPTS=""
  if [ -e "$APPDYNAMICS_APPLICATION_AGENT_JAR_FILE" ]; then
    export JAVA_OPTS="$JAVA_OPTS -javaagent:$APPDYNAMICS_APPLICATION_AGENT_JAR_FILE "
  else
    echo "AppDynamics Java Agent not found (APPDYNAMICS_APP_AGENT_JAR_FILE): $APPDYNAMICS_APPLICATION_AGENT_JAR_FILE"
    exit 0
  fi
  export JAVA_OPTS=$JAVA_OPTS"-Djava.security.egd=file:/dev/./urandom "
  export JAVA_OPTS=$JAVA_OPTS"-Dappdynamics.low.entropy=true "
  export JAVA_OPTS=$JAVA_OPTS"-Dallow.unsigned.sdk.extension.jars=true "
  export JAVA_OPTS=$JAVA_OPTS"-Dappdynamics.analytics.agent.url=$APPDYNAMICS_ANALYTICS_AGENT_URL "

  clear
  echo "JAVA_OPS [$JAVA_OPTS]"
  rm -rf nohup.out
  touch nohup.out

  # Stop
  echo "Stop running instance of $JAVA_TEST_APP_JAR"
  ps -ef | grep "$JAVA_TEST_APP_JAR" ; sleep 1
  pkill -f "$JAVA_TEST_APP_JAR" ; sleep 1


  PARAM_NODE_PORT=$((18080 + NODE_ID)) #18081, 18082, .....
  unset APPDYNAMICS_AGENT_TIER_NAME
  unset APPDYNAMICS_AGENT_NODE_NAME

  APPD_OPTIONS=""
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.applicationName=$APPDYNAMICS_APPLICATION_NAME "
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.tierName=JAVA_TIER_T1 "
  APPD_OPTIONS=$APPD_OPTIONS"-Dappdynamics.agent.nodeName=JAVA_NODE_N$NODE_ID"
  echo "Starting: Node: $NODE_ID on Port: $PARAM_NODE_PORT AppName: $APPDYNAMICS_APPLICATION_NAME"
  nohup java $JAVA_OPTS $APPD_OPTIONS -jar $JAVA_TEST_APP_JAR $PARAM_NODE_PORT &

  _tailLog 300 nohup.out
}
