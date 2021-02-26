#!/bin/bash

function readImageNames() {
  IFS=$'\n'
  grep -v '^ *#' < .env | while IFS= read -r line
  do

    if [ "${line:0:11}" == "SCRIPT_NAME" ]; then
      echo "${line:12}"
      return $?
    else
      echo "没有识别到配置docker脚本名称，程序退出"
      exit 7
    fi

  done
}

function syncDeploy() {
  echo "同步最新脚本"
  if [ -f "./my_crontab_list.sh" ]; then
    mv ./my_crontab_list.sh ./my_crontab_list.sh.bak
  fi

  if [ -f "./deploy.sh" ]; then
    mv ./deploy.sh ./deploy.sh.bak
  fi
  
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/my_crontab_list.sh -O ./my_crontab_list.sh
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/deploy.sh -O ./deploy.sh
  chmod 777 ./deploy.sh

  echo "执行脚本任务"
  exec sh ./deploy.sh start
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
}

function runDocker() {
  echo "docker task start"
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

    echo "宠汪汪兑换"
    docker cp ./joy_reword.js "$image":/scripts/joy_reword.js

    echo "华硕-爱奇艺"
    docker cp ./jd_asus_iqiyi.js "$image":/scripts/jd_asus_iqiyi.js

    echo "跳一跳"
    docker cp ./jd_jump-jump.js "$image":/scripts/jd_jump-jump.js

    echo "百变大咖秀"
    docker cp ./jd_entertainment.js "$image":/scripts/jd_entertainment.js

    echo "粉丝互动"
    docker cp ./jd_fanslove.js "$image":/scripts/jd_fanslove.js

    echo "财富岛任务"
    docker cp ./jx_cfd.js "$image":/scripts/jx_cfd.js

    echo "财富岛通知"
    docker cp ./jx_cfd_exchange.js "$image":/scripts/jx_cfd_exchange.js

    echo "格式化互助码"
    docker cp ./format_share_jd_code.js "$image":/scripts/format_share_jd_code.js

    echo "重新安装node包"
    docker exec -it "$image" sh -c 'npm i'

  done
}


imageNames=$(readImageNames)

if [ "$1" != "start" ]; then
  syncDeploy
fi

downScript

runDocker

initScript "$imageNames"

rm -rf *.js


