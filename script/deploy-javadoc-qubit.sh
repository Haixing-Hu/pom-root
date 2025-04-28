#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <project>"
    exit 1
fi

PROJECT=$1
USER=dev
HOST=dev.qubit.ltd
PORT=22222
URL_PREFIX=https://dev.qubit.ltd/javadoc
TARGET_DIR=/var/www/html/javadoc/${PROJECT};

mvn clean generate-resources javadoc:javadoc
ssh -p ${PORT} ${USER}@${HOST} "sudo rm -rvf ${TARGET_DIR}"
ssh -p ${PORT} ${USER}@${HOST} "sudo mkdir -p ${TARGET_DIR}"
ssh -p ${PORT} ${USER}@${HOST} "sudo chown -R dev:developer ${TARGET_DIR}"
scp -P ${PORT} -r target/site/apidocs/* ${USER}@${HOST}:${TARGET_DIR}/
ssh -p ${PORT} ${USER}@${HOST} "chmod a+rx ${TARGET_DIR}"
ssh -p ${PORT} ${USER}@${HOST} "chmod -R a+r ${TARGET_DIR}"
echo "Javadoc deployed to ${URL_PREFIX}/${PROJECT}/"
