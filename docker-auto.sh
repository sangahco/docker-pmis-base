#!/usr/bin/env bash

set -e

DOCKER_COMPOSE_VERSION="1.14.0"
CONF_ARG="-f docker-compose.yml"

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

PROJECT_NAME="$PROJECT_NAME"
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$(cat .env | awk 'BEGIN { FS="="; } /^PROJECT_NAME/ {sub(/\r/,"",$2); print $2;}')"
fi
REGISTRY_URL="$REGISTRY_URL"
if [ -z "$REGISTRY_URL" ]; then
    REGISTRY_URL="$(cat .env | awk 'BEGIN { FS="="; } /^REGISTRY_URL/ {sub(/\r/,"",$2); print $2;}')"
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo
echo "Options:"
echo "  --help          Show this help message"
echo
echo "Commands:"
echo "  up              Start the services"
echo "  down            Stop the services"
echo "  ps              Show the status of the services"
echo "  logs            Follow the logs on console"
echo "  login           Log in to a Docker registry"
echo "  remove-all      Remove all containers"
echo "  stop-all        Stop all containers running"
echo "  build           Build the image"
echo "  publish         Publish the image to the registry"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --help|-h)
        usage
        exit 1
        ;;
    *)
        ;;
esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "login" ]; then
    docker login $REGISTRY_URL
    exit 0

elif [ "$1" == "up" ]; then
    docker-compose $CONF_ARG pull
    docker-compose $CONF_ARG build --pull
    docker-compose $CONF_ARG up -d --remove-orphans
    exit 0

elif [ "$1" == "stop-all" ]; then
    if [ -n "$(docker ps --format {{.ID}})" ]
    then docker stop $(docker ps --format {{.ID}}); fi
    exit 0

elif [ "$1" == "remove-all" ]; then
    if [ -n "$(docker ps -a --format {{.ID}})" ]
    then docker rm $(docker ps -a --format {{.ID}}); fi
    exit 0

elif [ "$1" == "logs" ]; then
    shift
    docker-compose $CONF_ARG logs -f --tail 200 "$@"
    exit 0

elif [ "$1" == "build" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$PROJECT_NAME" ]; then echo "PROJECT_NAME not defined."; exit 1; fi
    
    docker build -t $REGISTRY_URL/$PROJECT_NAME was
    exit 0

elif [ "$1" == "publish" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$PROJECT_NAME" ]; then echo "PROJECT_NAME not defined."; exit 1; fi
    
    docker login $REGISTRY_URL
    docker push $REGISTRY_URL/$PROJECT_NAME
    exit 0
fi

docker-compose $CONF_ARG "$@"
