#!/bin/bash

echo "****************"
echo "* Building jar!*"
echo "****************"

PROJ=/home/hector/jenkins-by-sample/12_Jenkins_CI_CD_Pipeline_Docker_Maven/pipeline
docker run --rm -v /root/.m2:/root/.m2 -v $PROJ/java-app:/app -w /app maven:3-alpine "$@"
