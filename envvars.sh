#!/bin/bash
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
# Required environment variables for AppDynamics AWS Lambda Lab 1
#
##############################################################################
# AWS Account
#
export AWS_REGION="us-west-1"
export AWS_ACCOUNT_ID="REQUIRED_AAI"
#
##############################################################################
# AWS Lambda Function
#
export AWS_LAMBDA_FUNCTION_NAME="APPD-FN-1"
export AWS_LAMBDA_RUNTIME="java8"
export AWS_LAMBDA_HANDLER="lambda.TestFn1"
export AWS_LAMBDA_ZIP_FILE="LambdaFunction/target/LambdaFunction-0.0.1-SNAPSHOT.jar"
export AWS_LAMBDA_ROLE_NAME="APPD-LAMBDA-R1"
#
##############################################################################
# AWS API Gateway
#
export AWS_API_NAME="APPD-API-1"
export AWS_API_STAGE="PROD"
export AWS_API_HTTP_METHOD="POST"
export AWS_API_PATH="APPDTEST1"
export AWS_API_KEY='""'
#
##############################################################################
# Apache Maven
# https://maven.apache.org/download.cgi
export MAVEN_BASE_FILE="apache-maven-3.6.2"
export MAVEN_DOWNLOAD_FILE="$MAVEN_BASE_FILE-bin.tar.gz"
export MAVEN_APACHE_DOWNLOAD_MIRROR="apache-mirror.8birdsvideo.com"
#
##############################################################################
# Java Test application
#
export JAVA_TEST_APP_JAR="JavaApp/target/pkg1-0.0.1-SNAPSHOT-jar-with-dependencies.jar "
export JAVA_TEST_APP_TIER_NAME="JAVA_TIER_T1"
export JAVA_TEST_APP_NODE_NAME="JAVA_NODE_N"
#
##############################################################################
# AppDynamics Agents
#
export APPDYNAMICS_APPLICATION_AGENT_JAR_FILE="AppServerAgent/javaagent.jar"
export APPDYNAMICS_MACHINE_AGENT_DIR="MachineAgent"
#
##############################################################################
# AppDynamics SaaS Controller
# https://docs.appdynamics.com/display/PRO45/Set+Up+the+Serverless+APM+Environment
export APPDYNAMICS_AGENT_ACCOUNT_NAME="REQUIRED_AAAN"
export APPDYNAMICS_GLOBAL_ACCOUNT_NAME="REQUIRED_AGNN"
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="REQUIRED_AAAAK"
export APPDYNAMICS_CONTROLLER_HOST_NAME="REQUIRED_ACHN"
export APPDYNAMICS_SERVERLESS_API_ENDPOINT="https://pdx-sls-agent-api.saas.appdynamics.com"
export APPDYNAMICS_CONTROLLER_PORT="443"
export APPDYNAMICS_CONTROLLER_SSL_ENABLED="true"
#
export APPDYNAMICS_APPLICATION_NAME="DDR_LAMBDA_TEST_1"
export APPDYNAMICS_TIER_NAME="LAMBDA_TIER_T1"
export APPDYNAMICS_NODE_NAME="LAMBDA_NODE_N1"
export APPDYNAMICS_LOG_LEVEL="DEBUG"
#
##############################################################################
# AppDynamics SaaS Controller Additionals for Agents
#
# Account Access
export APPDYNAMICS_ANALYTICS_API_KEY="NOT_REQUIRED"
#
# Events Service
export APPDYNAMICS_ANALYTICS_AGENT_URL=http://localhost:9090/v2/sinks/bt
export APPDYNAMICS_EVENTS_SERVICE_ENDPOINT_LOCAL=""
export APPDYNAMICS_EVENTS_SERVICE_ENDPOINT=""
#
export APPDYNAMICS_SIM_ENABLED=true
#
##############################################################################
# Test HTTP POST payload data
export APPD_POST_DATA='{ "address": "302 2nd Street", "city": "San Francisco", "zip": "94107" }'
#
#
