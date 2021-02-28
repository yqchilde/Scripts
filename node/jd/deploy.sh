#!/bin/bash

function readImageNames() {
  for line in `cat .env`
  do
    if [ "${line:0:12}" == "SCRIPT_NAME=" ]; then
      echo "读到脚本配置: ${line:12}"
      return $?
    fi
  done

  return 1
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
  chmod 700 ./deploy.sh

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
  wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_shake.js
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

    echo "docker copy joy_reword.js"
    docker cp ./joy_reword.js "$image":/scripts/joy_reword.js

    echo "docker copy jd_asus_iqiyi.js"
    docker cp ./jd_asus_iqiyi.js "$image":/scripts/jd_asus_iqiyi.js

    echo "docker copy jd_jump-jump.js"
    docker cp ./jd_jump-jump.js "$image":/scripts/jd_jump-jump.js

    echo "docker copy jd_entertainment.js"
    docker cp ./jd_entertainment.js "$image":/scripts/jd_entertainment.js

    echo "docker copy jd_fanslove.js"
    docker cp ./jd_fanslove.js "$image":/scripts/jd_fanslove.js

    echo "docker copy jx_cfd.js"
    docker cp ./jx_cfd.js "$image":/scripts/jx_cfd.js

    echo "docker copy jx_cfd_exchange.js"
    docker cp ./jx_cfd_exchange.js "$image":/scripts/jx_cfd_exchange.js

    echo "docker copy format_share_jd_code.js"
    docker cp ./format_share_jd_code.js "$image":/scripts/format_share_jd_code.js

    echo "docker copy jd_shake.js"
    docker cp ./jd_shake.js "$image":/scripts/jd_shake.js

    echo "重新安装node包"
    echo "$image"
    docker exec -it "$image" sh -c 'npm i'

  done
}

function main() {
  imageNames=`readImageNames`

  if [ $? -ne 0 ]; then
    echo "没有识别到配置docker脚本名称，程序退出"
    exit 1
  fi

  if [ ! `command -v wget` ];then
      echo "发现wget没有安装，程序退出"
      exit 1
  fi

  if [ "$1" != "start" ]; then
    syncDeploy
  fi

  downScript

  runDocker

  initScript "$imageNames"

  rm -rf *.js
}

main




