#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RES=$(tput sgr0)

function readImageNames() {
  for line in `cat .env`
  do
    if [ "${line:0:12}" == "SCRIPT_NAME=" ]; then
      export SCRIPT_NAMES=${line:12}
      return $?
    fi
  done

  return 1
}

function syncDeploy() {
  echo -e "${GREEN}同步最新脚本${RES}"
  if [ -f "./my_crontab_list.sh" ]; then
    mv ./my_crontab_list.sh ./my_crontab_list.sh.bak
  fi

  if [ -f "./deploy.sh" ]; then
    mv ./deploy.sh ./deploy.sh.bak
  fi

  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/my_crontab_list.sh -O ./my_crontab_list.sh
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/deploy.sh -O ./deploy.sh
  chmod 700 ./deploy.sh

  echo -e "${GREEN}执行脚本任务${RES}"
  exec bash deploy.sh start
}

function downScript() {
  wget https://raw.sevencdn.com/yqchilde/Scripts/main/node/jd/joy_reword.js -O ./joy_reword.js
  wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_asus_iqiyi.js -O ./jd_asus_iqiyi.js
  wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_jump-jump.js -O ./jd_jump-jump.js
  wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_entertainment.js -O ./jd_entertainment.js
  wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_fanslove.js -O ./jd_fanslove.js
  wget https://raw.sevencdn.com/moposmall/Script/main/Me/jx_cfd.js -O ./jx_cfd.js
  wget https://raw.sevencdn.com/moposmall/Script/main/Me/jx_cfd_exchange.js -O ./jx_cfd_exchange.js
  wget https://gitee.com/qq34347476/quantumult-x/raw/master/format_share_jd_code.js -O ./format_share_jd_code.js
  wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_shake.js
}

function runDocker() {
  echo -e "${GREEN}docker task start${RES}"
  docker-compose down
  docker rmi lxk0301/jd_scripts
  docker-compose up -d
}

function initScript() {
  str="$1"
  OLD_IFS="$IFS"
  IFS="@"
  arr=($str)
  IFS="$OLD_IFS"

  for image in "${arr[@]}"
  do

    echo -e "${BLUE}docker copy joy_reword.js${RES}"
    docker cp ./joy_reword.js "$image":/scripts/joy_reword.js

    echo -e "${BLUE}docker copy jd_asus_iqiyi.js${RES}"
    docker cp ./jd_asus_iqiyi.js "$image":/scripts/jd_asus_iqiyi.js

    echo -e "${BLUE}docker copy jd_jump-jump.js${RES}"
    docker cp ./jd_jump-jump.js "$image":/scripts/jd_jump-jump.js

    echo -e "${BLUE}docker copy jd_entertainment.js${RES}"
    docker cp ./jd_entertainment.js "$image":/scripts/jd_entertainment.js

    echo -e "${BLUE}docker copy jd_fanslove.js${RES}"
    docker cp ./jd_fanslove.js "$image":/scripts/jd_fanslove.js

    echo -e "${BLUE}docker copy jx_cfd.js${RES}"
    docker cp ./jx_cfd.js "$image":/scripts/jx_cfd.js

    echo -e "${BLUE}docker copy jx_cfd_exchange.js${RES}"
    docker cp ./jx_cfd_exchange.js "$image":/scripts/jx_cfd_exchange.js

    echo -e "${BLUE}docker copy format_share_jd_code.js${RES}"
    docker cp ./format_share_jd_code.js "$image":/scripts/format_share_jd_code.js

    echo -e "${BLUE}docker copy jd_shake.js${RES}"
    docker cp ./jd_shake.js "$image":/scripts/jd_shake.js

    echo -e "${GREEN}Exec npm i${RES}"
    echo "$image"
    docker exec -it "$image" sh -c 'npm i'

  done
}

function main() {
  readImageNames

  if [ $? -ne 0 ]; then
    echo -e "${RED}没有识别到配置docker脚本名称，程序退出${RES}"
    exit 1
  fi

  if [ ! `command -v wget` ];then
      echo -e "${RED}发现wget没有安装，程序退出${RES}"
      exit 1
  fi

  if [ "$1" != "start" ]; then
    syncDeploy
  fi

  downScript

  runDocker

  initScript $SCRIPT_NAMES

  rm -rf *.js
}

main




