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
export AWS_ACCOUNT_ID="REQUIRED"
#
##############################################################################
# AWS Lambda Function
#
export AWS_LAMBDA_FUNCTION_NAME="APPD-FN-1"
export AWS_LAMBDA_RUNTIME="java8"
export AWS_LAMBDA_HANDLER="lambda.Test1"
export AWS_LAMBDA_ZIP_FILE="LambdaFunction/target/LambdaFunction-0.0.1-SNAPSHOT.jar"
#
##############################################################################
# AWS API Gateway
#
export AWS_API_NAME="APPD_API_1"
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
#
##############################################################################
# AppDynamics Agents
#
export APPDYNAMICS_APPLICATION_AGENT_JAR_FILE="AppServerAgent-4.5.15.28231/javaagent.jar"
export APPDYNAMICS_MACHINE_AGENT_DIR="MachineAgent"
#
##############################################################################
# AppDynamics SaaS Controller
# https://docs.appdynamics.com/display/PRO45/Set+Up+the+Serverless+APM+Environment
export APPDYNAMICS_ACCOUNT_NAME="REQUIRED"
export APPDYNAMICS_GLOBAL_ACCOUNT_NAME="REQUIRED"
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="REQUIRED"
export APPDYNAMICS_CONTROLLER_HOST="REQUIRED"
export APPDYNAMICS_SERVERLESS_API_ENDPOINT=https://pdx-sls-agent-api.saas.appdynamics.com
export APPDYNAMICS_CONTROLLER_PORT=443
export APPDYNAMICS_APPLICATION_NAME=LAMBDA_TEST_1
export APPDYNAMICS_TIER_NAME=LAMBDA_TIER_T1
export APPDYNAMICS_NODE_NAME=LAMBDA_NODE_N1
export APPDYNAMICS_LOG_LEVEL=DEBUG
#
##############################################################################
#
