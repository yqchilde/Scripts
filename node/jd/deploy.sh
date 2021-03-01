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
  echo -e "${GREEN}------------------------------------------------同步最新脚本------------------------------------------------${RES}"
  if [ -f "./my_crontab_list.sh" ]; then
    mv ./my_crontab_list.sh ./my_crontab_list.sh.bak
  fi

  if [ -f "./deploy.sh" ]; then
    mv ./deploy.sh ./deploy.sh.bak
  fi

  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/my_crontab_list.sh -O ./my_crontab_list.sh
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/deploy.sh -O ./deploy.sh
  chmod 700 ./deploy.sh

  if [ ! -f "./deploy.sh" ] || [ ! -s "./deploy.sh" ]; then
    echo -e "${RED}因网络原因导致脚本同步失败，程序退出${RES}"
    cp ./deploy.sh.bak ./deploy.sh
    exit 1
  else
    echo -e "${GREEN}------------------------------------------------执行脚本任务------------------------------------------------${RES}"
    exec bash deploy.sh start
  fi
}

function downScript() {
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/author/lxk0301/joy_reword.js -O ./joy_reword.js
  wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_entertainment.js -O ./jd_entertainment.js
  wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_fanslove.js -O ./jd_fanslove.js
  wget https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_cfd_exchange.js -O ./jx_cfd_exchange.js
  wget https://gitee.com/qq34347476/quantumult-x/raw/master/format_share_jd_code.js -O ./format_share_jd_code.js
  wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_shake.js -O ./jd_shake.js
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/author/whyour/jx_cfdtx.js -O ./jx_cfdtx.js
  wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/author/lxk0301/jd_live_redrain.js -O ./jd_live_redrain.js
}

function runDocker() {
  echo -e "${GREEN}------------------------------------------------docker task start------------------------------------------------${RES}"
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

    {
      echo -e "${BLUE}docker copy joy_reword.js${RES}"
      docker cp ./joy_reword.js "$image":/scripts/joy_reword.js

      echo -e "${BLUE}docker copy jd_entertainment.js${RES}"
      docker cp ./jd_entertainment.js "$image":/scripts/jd_entertainment.js

      echo -e "${BLUE}docker copy jd_fanslove.js${RES}"
      docker cp ./jd_fanslove.js "$image":/scripts/jd_fanslove.js

      echo -e "${BLUE}docker copy jx_cfdtx.js${RES}"
      docker cp ./jx_cfdtx.js "$image":/scripts/jx_cfdtx.js

      echo -e "${BLUE}docker copy jx_cfd_exchange.js${RES}"
      docker cp ./jx_cfd_exchange.js "$image":/scripts/jx_cfd_exchange.js

      echo -e "${BLUE}docker copy format_share_jd_code.js${RES}"
      docker cp ./format_share_jd_code.js "$image":/scripts/format_share_jd_code.js

      echo -e "${BLUE}docker copy jd_shake.js${RES}"
      docker cp ./jd_shake.js "$image":/scripts/jd_shake.js
      
      echo -e "${BLUE}docker copy jd_live_redrain.js${RES}"
      docker cp ./jd_shake.js "$image":/scripts/jd_live_redrain.js

      echo -e "${GREEN}------------------------------------------------Exec Npm Install------------------------------------------------${RES}"
      docker exec -it "$image" /bin/bash -c 'npm config set registry https://registry.npm.taobao.org && npm install'
    }&

  done
  wait
}

function main() {
  if [ "$1" != "start" ]; then
    echo -e "${GREEN}                       _ ____    ____            _       _
                      | |  _ \  / ___|  ___ _ __(_)_ __ | |_
                   _  | | | | | \___ \ / __| '__| | '_ \| __|
                  | |_| | |_| |  ___) | (__| |  | | |_) | |_
                   \___/|____/  |____/ \___|_|  |_| .__/ \__|
                                                  |_|
                      ____        _ _     _ _
                     | __ ) _   _(_) | __| (_)_ __   __ _
                     |  _ \| | | | | |/ _\` | | '_ \ / _\` |
                     | |_) | |_| | | | (_| | | | | | (_| |
                     |____/ \__,_|_|_|\__,_|_|_| |_|\__, |
                                                    |___/${RES}"
  fi

  readImageNames

  if [ $? -ne 0 ]; then
    echo -e "${RED}未检查到配置脚本多账号容器名称，程序退出，详情请查看 https://github.com/yqchilde/Scripts/tree/main/node/jd${RES}"
    exit 1
  fi

  if [ ! `command -v wget` ];then
      echo -e "${RED}未检查到wget安装，程序退出${RES}"
      exit 1
  fi

  if [ "$1" != "start" ]; then
    syncDeploy
  fi

  downScript &

  runDocker &

  wait

  initScript $SCRIPT_NAMES

  rm -rf *.js

  unset SCRIPT_NAMES

  echo -e "${GREEN}   ____     __ __
  / __ \   / //_/
 / / / /  / ,<
/ /_/ /  / /| |
\____/  /_/ |_|${RES}"
}

main $1
