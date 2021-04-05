#!/bin/bash

# reload  重载配置
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
fi
