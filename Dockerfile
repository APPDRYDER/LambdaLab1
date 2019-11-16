FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip curl jq maven awscli
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

CMD /bin/bash
