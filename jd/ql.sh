#!/usr/bin/env bash

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/api.sh
dir_scripts=/ql/scripts

author_repo="curtinlv_JD-Script"

del_cron() {
    local detail=""
    local ids=""
    echo -e "开始尝试自动删除不正经的定时任务...\n"

    for author in $author_repo; do
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
          notify "$author 删除任务${result}" "$detail"
      fi
    done
}

ql_repo() {
  ql repo https://github.com/yqchilde/Scripts.git "jd_|jx_|diy_|getJDCookie" "backup" "^jd[^_]|USER" "jd"
  ql repo https://github.com/he1pu/JDHelp.git "jd_|jx_|getJDCookie" "activity|backUp|jd_delCoupon" "^jd[^_]|USER"
  ql repo https://github.com/longzhuzhu/nianyu.git "qx"
  ql repo https://github.com/whyour/hundun.git "quanx" "tokens|caiyun|didi|donate|fold|Env"
  ql repo https://github.com/Wenmoux/scripts.git "other|jd" "" "" "wen"
  ql repo https://github.com/panghu999/panghu.git "jd_"
  ql repo https://github.com/hyzaw/scripts.git "ddo_"
  ql repo https://github.com/star261/jd.git "scripts" "code"
  ql repo https://github.com/zooPanda/zoo.git "" "do_not_use" "" "dev"
  ql repo https://github.com/Ariszy/Private-Script.git "JD"
  ql repo https://github.com/ZCY01/daily_scripts.git "jd_"
  ql repo https://github.com/moposmall/Script.git "Me"
  ql repo https://github.com/photonmang/quantumultX.git "JDscripts"
}

ql_repo
del_cron

exit 0