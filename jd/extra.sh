#!/usr/bin/env bash

#Author: Yqchilde
#FileName:extra.sh
#Description: 青龙面板extra.sh内添加下面这行Usage命令，然后定时任务添加extra
#Usage: /bin/bash -c "$(curl -fsSL https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh)"
#URL(github): https://raw.githubusercontent.com/yqchilde/Scripts/main/jd/extra.sh
#URL(gitee): https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh
#UpdateDate: 2021-08-23 09:29:45

dir_shell=/ql/shell
dir_scripts=/ql/scripts
dir_config=/ql/config
. $dir_shell/share.sh
. $dir_shell/api.sh
. $dir_config/config.sh

author_repos=""
script_files=""
python_models="requests"
node_models="png-js axios date-fns"
declare -A scriptCronMap=(
  ["yqchilde_Scripts_jd_jd_blueCoin.js"]="59,0,1 59,0 0,23 * * *"
  ["yqchilde_Scripts_jd_jd_car_exchange.js"]="59,0,1 59,0 0,23 * * *"
  ["yqchilde_Scripts_jd_jd_mohe.js"]="5 0,1-23/3 * * *"
)

function notify() {
  title=$(echo -e "$1")
  msg=$(echo -e "$2")

  node ${dir_shell}/notify.js "$title" "$msg"
}

function del_ql_cron() {
  local del_repo_detail=""
  local del_repo_ids=""
  local del_single_detail=""
  local del_single_ids=""

  for author in $author_repos; do
    # 特判
    files=$(ls $dir_scripts/$author* 2>/dev/null | sed -e "s/^\/ql\/scripts\///" | wc -l)
    if [[ "$files" == "0" ]]; then
      echo "🙅‍️ 未发现 $author 仓库脚本，跳过"
      continue
    fi
    echo -e "👉 开始尝试删除 $author 的不正经脚本"
    for cron in $(ls $dir_scripts/$author* | sed -e "s/^\/ql\/scripts\///"); do
      del_repo_id=$(cat $list_crontab_user | grep -E "$cmd_task $cron" | perl -pe "s|.*ID=(.*) $cmd_task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
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
      echo -e "👇 $author 删除任务${result}"
      echo -e "$del_repo_detail"
      if [[ $result == "成功" ]]; then
        notify "$author 删除任务${result}" "$del_repo_detail"
      fi
    fi
  done

  for file in $script_files; do
    # 特判
    if [[ ! -f $file ]]; then
      echo "🙅 未发现 $file 脚本，跳过"
      continue
    fi
    echo -e "👉 开始尝试删除 $file 单脚本"
    for cron in $file; do
      del_single_id=$(cat $list_crontab_user | grep -E "$cmd_task $cron" | perl -pe "s|.*ID=(.*) $cmd_task $cron|\1|" | xargs | sed 's/ /","/g' | head -1)
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
    echo -e "👇 单脚本删除${result}"
    echo -e "$del_single_detail"
    if [[ $result == "成功" ]]; then
      notify "单脚本删除${result}" "$del_single_detail"
    fi
  fi
  if [[ -z "$del_repo_detail" && -z "$del_single_detail" ]]; then
    echo "🙅 当前没有需要删除的脚本"
  fi
}

function exec_ql_repo() {
  ql repo https://github.com/yqchilde/Scripts.git "jd_|jx_|getJDCookie" "" "^jd[^_]|USER|utils" "jd"
  ql repo https://github.com/longzhuzhu/nianyu.git "qx"
  ql repo https://github.com/ZCY01/daily_scripts.git "jd_"
  ql repo https://github.com/smiek2221/scripts.git "jd_|gua_" "gua_wealth_island*|jd_joy|jd_joy_steal|jd_necklace|gua_carnivalcity" "sign_graphics_validate.js"
  ql repo https://github.com/Tsukasa007/my_script.git "" "jdCookie|USER_AGENTS|sendNotify|backup|zlmjh|smzdm_mission|jd_qjd" "" "master"
}

function add_python_model() {
  local add_model_detail=""
  for python_model in $python_models; do
    if ! python3 -c "import $python_model" 2>/dev/null; then
      echo "👀 检测到Python环境中 $python_model 模块不存在，尝试安装"
      if pip3 install "$python_model" 2>/dev/null; then
        if [[ $add_model_detail ]]; then
          add_model_detail="${add_model_detail}\n${python_model}"
        else
          add_model_detail="${python_model}"
        fi
      fi
    fi
  done
  if [ -n "$add_model_detail" ]; then
    echo -e "🙆 Python环境尝试添加模块成功\n$add_model_detail"
    notify "Python环境尝试添加模块成功" "$add_model_detail"
  else
    echo "🙅 当前Python环境没有未安装的模块"
  fi
}

function add_node_model() {
  local add_model_detail=""
  for node_model in $node_models; do
    if ! npm list "$node_model" 1>/dev/null; then
      echo "👀 检测到Node环境中 $node_model 模块不存在，尝试安装"
      if npm i -S "$node_model" 2>/dev/null; then
        if [[ $add_model_detail ]]; then
          add_model_detail="${add_model_detail}\n${node_model}"
        else
          add_model_detail="${node_model}"
        fi
      fi
    fi
  done
  if [ -n "$add_model_detail" ]; then
    echo -e "🙆 Node环境尝试添加模块成功\n$add_model_detail"
    notify "Node环境尝试添加模块成功" "$add_model_detail"
  else
    echo "🙅 当前Node环境没有未安装的模块"
  fi
}

function modify_script_cron() {
  if [[ "${#scriptCronMap[@]}" == "0" ]]; then
    echo "🙅 当前没有需要修改定时的脚本"
    return
  fi

  local modify_cron_detail=""
  for script in "${!scriptCronMap[@]}"; do
    cron_new_exp="${scriptCronMap[$script]}"
    cron_old_exp=$(cat $list_crontab_user | grep -E "$cmd_task $script" | perl -pe "s|(.*) ID=(.*) $cmd_task $script\.*|\1|" | head -1)
    cron_id=$(cat $list_crontab_user | grep -E "$cmd_task $script" | perl -pe "s|.*ID=(.*) $cmd_task $script\.*|\1|" | head -1) && cd "$dir_scripts"
    cron_name=$(grep "new Env" "$script" | awk -F "\(" '{print $2}' | awk -F "\)" '{print $1}' | sed 's:^.\(.*\).$:\1:' | head -1) && cd "$dir_config"
    [[ -z $cron_name ]] && cron_name="$script"
    if [[ ${cron_old_exp} == *${cron_new_exp}* ]]; then
      echo "🤷 ${cron_name} 与当前cron一致，跳过"
      continue
    fi
    if [[ -n $cron_id ]]; then
      result=$(update_cron_api "$cron_new_exp:$cmd_task $script:$cron_name:$cron_id")
      if [[ $result == *成功* ]]; then
        if [[ $modify_cron_detail ]]; then
          modify_cron_detail="${modify_cron_detail}\n${cron_name} -> cron(${cron_new_exp})"
        else
          modify_cron_detail="${cron_name} -> cron(${cron_new_exp})"
        fi
      else
        echo "❌ $result"
      fi
    fi
  done
  if [ -n "$modify_cron_detail" ]; then
    echo -e "👉 cron表达式测试地址：https://crontab.guru\n👇 以下脚本修改定时成功\n\n${modify_cron_detail}"
    notify "脚本Cron表达式修改通知" "👉 cron表达式测试地址：https://crontab.guru\n👇 以下脚本修改定时成功\n\n${modify_cron_detail}"
  else
    echo "🙅 当前没有需要修改定时的脚本"
  fi
}

function main() {
  # 删除任务
  echo -e "\n️1️⃣ 🙋 开始检测是否存在需要删除的脚本\n"
  del_ql_cron

  # 安装python依赖
  echo -e "\n2️⃣ 🙋 开始检测Python依赖\n"
  add_python_model

  # 安装Node依赖
  echo -e "\n️️3️⃣ 🙋 开始检测Node依赖\n"
  add_node_model

  # 修改脚本定时
  echo -e "\n️4️⃣ 🙋 开始检查脚本定时是否有修改\n"
  modify_script_cron

  # 青龙拉取
  echo -e "\n️5️⃣ 🙋 开始从所有收集的脚本仓库拉取脚本\n"
  exec_ql_repo
}

main
exit 0
