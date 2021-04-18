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

cp $(find /ybRepo/jd/scripts/author -type f -name "*.js") /scripts/

{
  printf "# 手机狂欢城\n2 0-18/6 1-20 4 * node /scripts/z_carnivalcity.js >> /scripts/logs/z_carnivalcity.log 2>&1\n"
  printf "# 百变大咖秀\n10 10,11 * * 2-5 node /scripts/z_entertainment.js >> /scripts/logs/z_entertainment.log 2>&1\n"
  printf "# 粉丝互动\n3 10 * * * node /scripts/z_fanslove.js >> /scripts/logs/z_fanslove.log 2>&1\n"
  printf "# 京东超市-大转盘\n3 10 * * * node /scripts/z_marketLottery.js >> /scripts/logs/z_marketLottery.log 2>&1\n"
  printf "# 母婴跳一跳\n5 8,14,20 13-19 4 * node /scripts/z_mother_jump.js >> /scripts/logs/z_mother_jump.log 2>&1\n"
  printf "# 超级摇一摇\n3 20 * * * node /scripts/z_shake.js >> /scripts/logs/z_shake.log 2>&1\n"
  printf "# 5G超级盲盒\n5 1,6,11,16,21 * 3-4 * node /scripts/z_super5g.js >> /scripts/logs/z_super5g.log 2>&1\n"
  printf "# 京东小魔方\n10 10 7-9 4 * node /scripts/z_xmf.js >> /scripts/logs/z_xmf.log 2>&1\n"
  printf "# interCenter渠道店铺签到\n0 0 * * * node /scripts/monk_inter_shop_sign.js >> /scripts/logs/monk_inter_shop_sign.log 2>&1\n"
  printf "# 有机牧场\n0 0,1-22/2 1-31 4-7 * node /scripts/monk_pasture.js >> /scripts/logs/monk_pasture.log 2>&1\n"
  printf "# 店铺加购有礼\n15 12 * * * node /scripts/monk_shop_add_to_car.js >> /scripts/logs/monk_shop_add_to_car.log 2>&1\n"
  printf "# 店铺关注有礼\n15 15 * * * node /scripts/monk_shop_follow_sku.js >> /scripts/logs/monk_shop_follow_sku.log 2>&1\n"
  printf "# 店铺大转盘\n3 0,10,23 * * * node /scripts/monk_shop_lottery.js >> /scripts/logs/monk_shop_lottery.log 2>&1\n"
  printf "# 下班全勤奖\n15 08 2-18 4 * node /scripts/monk_skyworth_car.js >> /scripts/logs/monk_skyworth_car.log 2>&1\n"
  printf "# Vinda-维达品牌日\n15 08 5-30 4 * node /scripts/monk_vinda.js >> /scripts/logs/monk_vinda.log 2>&1\n"
} >> /scripts/docker/merged_list_file.sh
