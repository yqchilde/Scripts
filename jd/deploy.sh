#!/bin/bash

# reload  重新拉取脚本
# restart 重启脚本，不会重新拉取镜像
# reset   重置脚本，会再次拉取镜像

if [ "$1" == "reload" ]; then
    for container_id in `docker ps -aqf "name=jd"`; do
        docker exec -it $container_id sh -c "docker_entrypoint.sh"
    done
elif [ "$1" == "restart" ]; then
  docker-compose down
  docker-compose up -d
elif [ "$1" == "reset" ]; then
  docker-compose down
  docker rmi lxk0301/jd_scripts
  docker-compose up -d
elif [ "$1" == "exec" ]; then
    for container_id in `docker ps -aqf "name=jd"`; do
        docker exec -it $container_id sh -c "node /scripts/$2.js >> /scripts/logs/$2.log 2>&1"
        docker exec -it $container_id sh -c "sh +x /scripts/docker/auto_help.sh collect >> /scripts/logs/auto_help_collect.log 2>&1"
    done
fi
