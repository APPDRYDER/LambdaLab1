FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip curl sudo jq maven awscli
# openjdk-8-jdk

# Timezone
RUN cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
# Directories
WORKDIR /root
ENV ROOT_DIR=/root
ENV SW_DIR=/root
# Software
COPY *.sh             $SW_DIR/
COPY Scripts          $SW_DIR/Scripts
COPY JavaApp          $SW_DIR/JavaApp
COPY LambdaFunction   $SW_DIR/LambdaFunction
# Add in AppDynamcis Agents
COPY AppServerAgent-4.5.15.28231.zip     $SW_DIR
COPY MachineAgent-4.5.14.2293.zip        $SW_DIR
COPY awslambdamonitor-2.0.1.zip          $SW_DIR
# Start the container
CMD /bin/bash
