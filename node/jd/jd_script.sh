#!/bin/bash

function initGitRepo() {
   git clone https://gitee.com/yqchilde/Scripts.git /ybRepo
}

if [ ! -d "/ybRepo/" ]; then
   echo "未检查到ybRepo仓库脚本，初始化下载相关脚本"
   initGitRepo
else
   echo "更新ybRepo脚本相关文件"
   git -C /ybRepo reset --hard
   git -C /ybRepo pull --rebase
fi

cp $(find /ybRepo/node/jd/author -type f -name "*.js") /scripts/

{

  printf "# 兑换500豆子\n3,6,9 0 8,16 * * * node /scripts/joy_reward.js >> /scripts/logs/joy_reward.log 2>&1\n"
  printf "# 母婴-跳一跳\n5 8,14,20 2-7 3 * node /scripts/jd_jump-jump.js >> /scripts/logs/jd_jump-jump.log 2>&1\n"
  printf "# 百变大咖秀\n10 10,11 * * 2-5 node /scripts/jd_entertainment.js >> /scripts/logs/jd_entertainment.log 2>&1\n"
  printf "# 粉丝互动\n3 10 * * * node /scripts/jd_fanslove.js >> /scripts/jd_fanslove.log 2>&1\n"
  printf "# 财富岛通知\n30 6,12,22 * * * node /scripts/jx_cfd_exchange.js >> /scripts/logs/jx_cfd_exchange.log 2>&1\n"
  printf "# 摇一摇活动\n3 20 * * * node /scripts/jd_shake.js >> /scripts/logs/jd_shake.log 2>&1\n"
  printf "# 财富岛提现\n0 0 * * * node /scripts/jx_cfdtx.js >> /scripts/logs/jx_cfdtx.log 2>&1\n"
  printf "# 红包雨\n30,31 20-23/1 5,9 3 * node /scripts/jd_live_redrain.js >> /scripts/logs/jd_live_redrain.log 2>&1\n"
  printf "# 京东小魔方\n10 10 * * * node /scripts/jd_xmf.js >> /scripts/logs/jd_xmf.log 2>&1\n"
} >> /scripts/docker/merged_list_file.sh
