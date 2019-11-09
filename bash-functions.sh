#!/bin/bash
#
#
# Copyright (c) AppDynamics Inc
# All rights reserved
#
# Maintainer: David Ryder, david.ryder@appdynamics.com
#
SECONDS_DAY=86440
SECONDS_WEEK=604800

_validateEnvironmentVars() {
  echo "Validating environment variables for $1"
  shift 1
  VAR_LIST=("$@") # rebuild using all args
  #echo $VAR_LIST
  for i in "${VAR_LIST[@]}"; do
     [ -z ${!i} ] && { echo "Environment variable not set: $i"; ERROR="1"; }
  done
  [ "$ERROR" == "1" ] && { echo "Exiting"; exit 1; }
}

_makeJsonEnvVars() {
  echo "Validating environment variables for $1"
  shift 1
  VAR_LIST=("$@") # rebuild using all args
  #echo $VAR_LIST
  for i in "${VAR_LIST[@]}"; do
     [ -z ${!i} ] && { echo "Environment variable not set: $i"; ERROR="1"; }
  done
  [ "$ERROR" == "1" ] && { echo "Exiting"; exit 1; }
}

_tailLog() {
  TIME_SEC=$1
  LOG_FILE=$2
  echo "Tailing $LOG_FILE for $TIME_SEC seconds"
  tail -f $LOG_FILE &
  TAIL_PID=$!
  echo "PID $TAIL_PID"
  (sleep $TIME_SEC; echo "Stopping $TAIL_PID"; kill -9 $TAIL_PID; echo "Stopped: tail -f nohup.out" ) &
}
