#!/bin/bash

get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

if [ ! -z "$4" ]
then
      echo "DOCKER_IMAGE_VERSION is NOT empty - $4"
      export DOCKER_IMAGE_VERSION="$4"
else
      echo "DOCKER_IMAGE_VERSION is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

if [ ! -z "$3" ]
then
      echo "DOCKER_NAME is NOT empty - $3"
      export DOCKER_NAME="$3"
else
      echo "DOCKER_NAME is empty"
      export DOCKER_NAME="v0.1"
fi

if [ ! -z "$1" ]
then
      echo "ACCOUNT_ID is NOT empty - $1"
      export ACCOUNT_ID="$1"
else
      echo "ACCOUNT_ID is empty - use 613477150601 my isengard account"
      export ACCOUNT_ID="613477150601"
fi

if [ ! -z "$2" ]
then
      echo "REGION is NOT empty - $2"
      export REGION="$2"
else
      echo "REGION is empty"
      export REGION="ap-southeast-1"
fi

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker build . -t $DOCKER_NAME:latest
docker tag $DOCKER_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$DOCKER_NAME:$DOCKER_IMAGE_VERSION
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$DOCKER_NAME:$DOCKER_IMAGE_VERSION
