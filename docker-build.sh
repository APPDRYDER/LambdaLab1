#!/bin/bash
#
# Copy in AppDynamcis agents
cp ~/Downloads/AppD-Downloads/AppServerAgent-4.5.15.28231.zip .
cp ~/Downloads/AppD-Downloads/MachineAgent-4.5.14.2293.zip .
cp ~/Downloads/AppD-Downloads/awslambdamonitor-2.0.1.zip .
ls -al *.zip
#
#
docker build -t lambdalab1 .
