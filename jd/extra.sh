#!/usr/bin/env bash

#Author: Yqchilde
#FileName:extra.sh
#Description: 青龙面板extra.sh内添加下面这行Usage命令，然后定时任务添加extra
#Usage: /bin/bash -c "$(curl -fsSL https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh)"
#URL(github): https://raw.githubusercontent.com/yqchilde/Scripts/main/jd/extra.sh
#URL(gitee): https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh
#UpdateDate: 2021-07-13 19:27:03

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/api.sh
dir_scripts=/ql/scripts

author_repos="moposmall_Script Ariszy_Private-Script photonmang_quantumultX"
script_files="raw_jd_qjd.py raw_jd_zjd.py"
python_models="requests"
node_models="png-js axios date-fns"

function del_ql_cron() {
  local del_repo_detail=""
  local del_repo_ids=""
  local del_single_detail=""
  local del_single_ids=""

  for author in $author_repos; do
    # 特判
    files=$(ls $dir_scripts/$author* 2>/dev/null | sed -e "s/^\/ql\/scripts\///" | wc -l)
    if [[ "$files" == "0" ]]; then
      echo "未发现 $author 仓库脚本，跳过"
      continue
    fi
    echo -e "开始尝试删除 $author 的不正经脚本"
    for cron in $(ls $dir_scripts/$author* | sed -e "s/^\/ql\/scripts\///"); do
      del_repo_id=$(cat $list_crontab_user | grep -E "task $cron" | perl -pe "s|.*ID=(.*) task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
      if [[ $del_repo_ids ]]; then
        del_repo_ids="$del_repo_ids,\"$del_repo_id\""
      else
        del_repo_ids="\"$del_repo_id\""
      fi
      cron_file="$dir_scripts/${cron}"
      if [[ -f $cron_file ]]; then
        cron_name=$(grep "new Env" "$cron_file" | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1)
        rm -f "$cron_file"
      fi
      [[ -z $cron_name ]] && cron_name="$cron"
      if [[ $del_repo_detail ]]; then
        del_repo_detail="${del_repo_detail}\n${cron_name}"
      else
        del_repo_detail="${cron_name}"
      fi
    done
    if [[ $del_repo_ids ]]; then
      result=$(del_cron_api "$del_repo_ids")
      echo -e "$author 删除任务${result}"
      echo -e "$del_repo_detail"
      if [[ $result == "成功" ]]; then
        notify "$author 删除任务${result}" "$del_repo_detail"
      fi
    fi
  done

  for file in $script_files; do
    # 特判
    if [[ ! -f $file ]]; then
      echo "未发现 $file 脚本，跳过"
      continue
    fi
    echo -e "开始尝试删除 $file 单脚本"
    for cron in $file; do
      del_single_id=$(cat $list_crontab_user | grep -E "task $cron" | perl -pe "s|.*ID=(.*) task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
      if [[ $del_single_ids ]]; then
        del_single_ids="$del_single_ids,\"$del_single_id\""
      else
        del_single_ids="\"$del_single_id\""
      fi
      cron_file="$dir_scripts/${cron}"
      if [[ -f $cron_file ]]; then
        cron_name=$(grep "new Env" "$cron_file" | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1)
        rm -f "$cron_file"
      fi
      [[ -z $cron_name ]] && cron_name="$cron"
      if [[ $del_single_detail ]]; then
        del_single_detail="${del_single_detail}\n${cron_name}"
      else
        del_single_detail="${cron_name}"
      fi
    done
  done
  if [[ $del_single_ids ]]; then
    result=$(del_cron_api "$del_single_ids")
    echo -e "单脚本删除${result}"
    echo -e "$del_single_detail"
    if [[ $result == "成功" ]]; then
      notify "单脚本删除${result}" "$del_single_detail"
    fi
  fi
}

function exec_ql_repo() {
  ql repo https://github.com/yqchilde/Scripts.git "jd_|jx_|getJDCookie" "backup" "^jd[^_]|USER|MovementFaker|JDJRValidator_Pure|sign_graphics_validate|ZooFaker_Necklace" "jd"
  ql repo https://github.com/longzhuzhu/nianyu.git "qx"
  ql repo https://github.com/whyour/hundun.git "quanx" "tokens|caiyun|didi|donate|fold|Env"
  ql repo https://github.com/ZCY01/daily_scripts.git "jd_"
  ql repo https://github.com/panghu999/panghu.git "jd_"
  ql repo https://github.com/smiek2221/scripts.git "jd_" "" "ZooFaker_Necklace.js|JDJRValidator_Pure.js|sign_graphics_validate.js"
  ql repo https://github.com/Tsukasa007/my_script.git "" "jdCookie|USER_AGENTS|sendNotify|backup|zlmjh|smzdm_mission" "" "master"
}

function add_python_model() {
  local add_model_detail=""
  for python_model in $python_models; do
    if ! python3 -c "import $python_model" 2>/dev/null; then
      echo "检测到Python环境中 $python_model 模块不存在，尝试安装"
      if pip3 install "$python_model" 2>/dev/null; then
        if [[ $add_model_detail ]]; then
          add_model_detail="${add_model_detail}\n${python_model}"
        else
          add_model_detail="${python_model}"
        fi
      fi
    else
      echo "当前Python环境没有未安装的模块"
    fi
  done
  if [ -n "$add_model_detail" ]; then
    echo -e "Python环境尝试添加模块成功\n$add_model_detail"
    notify "Python环境尝试添加模块成功" "$add_model_detail"
  fi
}

function add_node_model() {
  local add_model_detail=""
  for node_model in $node_models; do
    if ! npm list "$node_model" 1>/dev/null; then
      echo "检测到Node环境中 $node_model 模块不存在，尝试安装"
      if npm i "$node_model" 2>/dev/null; then
        if [[ $add_model_detail ]]; then
          add_model_detail="${add_model_detail}\n${node_model}"
        else
          add_model_detail="${node_model}"
        fi
      fi
    else
      echo "当前Node环境没有未安装的模块"
    fi
  done
  if [ -n "$add_model_detail" ]; then
    echo -e "Node环境尝试添加模块成功\n$add_model_detail"
    notify "Node环境尝试添加模块成功" "$add_model_detail"
  fi
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
