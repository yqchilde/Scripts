#!/usr/bin/env bash

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/api.sh
dir_scripts=/ql/scripts

author_repo=""
script_file="jd_qjd.py"
python_models="requests"
node_models="png-js"

function del_ql_cron() {
    for author in $author_repo; do
      detail=""
      ids=""
      echo -e "开始尝试删除 $author 的不正经脚本"

      for cron in $(ls $dir_scripts/$author* | sed -e "s/^\/ql\/scripts\///"); do
        local id=$(cat $list_crontab_user | grep -E "$cmd_task $cron" | perl -pe "s|.*ID=(.*) $cmd_task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
        if [[ $ids ]]; then
            ids="$ids,\"$id\""
        else
            ids="\"$id\""
        fi
        cron_file="$dir_scripts/${cron}"
        if [[ -f $cron_file ]]; then
            cron_name=$(grep "new Env" $cron_file | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1)
            rm -f $cron_file
        fi
        [[ -z $cron_name ]] && cron_name="$cron"
        if [[ $detail ]]; then
            detail="${detail}\n${cron_name}"
        else
            detail="${cron_name}"
        fi
      done
      if [[ $ids ]]; then
          result=$(del_cron_api "$ids")
          echo -e "$author 删除任务${result}"
          echo -e "$detail"
          if [[ $result == "成功" ]]; then
              notify "$author 删除任务${result}" "$detail"
          fi
      fi
    done

    for file in $script_file; do
      detail=""
      ids=""
      echo -e "开始尝试删除 $file 单脚本"

      for cron in $file; do
        local id2=$(cat $list_crontab_user | grep -E "$cmd_task $cron" | perl -pe "s|.*ID=(.*) $cmd_task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
        if [[ $ids ]]; then
            ids="$ids,\"$id2\""
        else
            ids="\"$id2\""
        fi
        cron_file="$dir_scripts/${cron}"
        if [[ -f $cron_file ]]; then
            cron_name=$(grep "new Env" $cron_file | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1)
            rm -f $cron_file
        fi
        [[ -z $cron_name ]] && cron_name="$cron"
        if [[ $detail ]]; then
            detail="${detail}\n${cron_name}"
        else
            detail="${cron_name}"
        fi
      done
      if [[ $ids ]]; then
          result=$(del_cron_api "$ids")
          echo -e "$file 单脚本删除${result}"
          echo -e "$detail"
          if [[ $result == "成功" ]]; then
              notify "$file 单脚本删除${result}" "$detail"
          fi
      fi
    done
}

function exec_ql_repo() {
  ql repo https://github.com/yqchilde/Scripts.git "jd_|jx_|getJDCookie" "backup" "^jd[^_]|USER|MovementFaker|JDJRValidator_Pure|sign_graphics_validate|ZooFaker_Necklace" "jd"
  ql repo https://github.com/longzhuzhu/nianyu.git "qx"
  ql repo https://github.com/whyour/hundun.git "quanx" "tokens|caiyun|didi|donate|fold|Env"
  ql repo https://github.com/Ariszy/Private-Script.git "JD"
  ql repo https://github.com/ZCY01/daily_scripts.git "jd_"
  ql repo https://github.com/moposmall/Script.git "Me"
  ql repo https://github.com/photonmang/quantumultX.git "JDscripts"
  ql repo https://github.com/panghu999/panghu.git "jd_"
  ql repo https://github.com/smiek2221/scripts.git "jd_" "" "ZooFaker_Necklace.js|JDJRValidator_Pure.js|sign_graphics_validate.js"
  ql repo https://github.com/Tsukasa007/my_script.git "" "jdCookie|USER_AGENTS|sendNotify|backup|zlmjh|smzdm_mission" "" "master"
}

function add_python_model() {
  for python_model in $python_models; do
    if ! python3 -c "import $python_model" 2>/dev/null; then
      echo "检测到Python环境中 $python_model 模块不存在，尝试安装"
      if pip3 install "$python_model" 2>/dev/null; then
        notify "Python环境尝试添加模块成功" "$python_model"
      fi
    fi
  done
}

function add_node_model() {
  for node_model in $node_models; do
    if ! npm list $node_model 1>/dev/null; then
      echo "检测到Node环境中 $node_model 模块不存在，尝试安装"
      if npm i png-js 2>/dev/null; then
        notify "Node环境尝试添加模块成功" "$node_model"
      fi
    fi
  done
}

function main() {
  # 删除任务
  echo -e "\n开始尝试自动删除不正经的定时任务\n"
  del_ql_cron

  # 安装python依赖
  echo -e "\n开始检测Python依赖\n"
  add_python_model

  # 安装Node依赖
  echo -e "\n开始检测Node依赖\n"
  add_node_model

  # 青龙拉取
  echo -e "\n开始从所有收集的脚本仓库拉取脚本\n"
  exec_ql_repo
}

main
exit 0
