#!/bin/bash

# 更新脚本
if [ ! -d "/ybRepo/" ]; then
   echo "未检查到ybRepo仓库脚本，初始化下载相关脚本"
   git clone https://gitee.com/yqchilde/Scripts.git /ybRepo
else
   echo "更新ybRepo脚本相关文件"
   git -C /ybRepo reset --hard
   git -C /ybRepo pull --rebase
fi

# 复制脚本
cp $(find /ybRepo/jd/scripts/author -type f -name "*.js") /scripts/

# 添加定时任务
{
  printf "# 百变大咖秀\n10 10,11 * * 2-5 node /scripts/diy_entertainment.js >> /scripts/logs/diy_entertainment.log 2>&1\n"
  printf "# 粉丝互动\n3 10 * * * node /scripts/diy_fanslove.js >> /scripts/logs/diy_fanslove.log 2>&1\n"
  printf "# 健康社区\n25 10-22/3 * * * node /scripts/diy_health_community.js >> /scripts/logs/diy_health_community.log 2>&1\n"
  printf "# 健康社区收取能量\n25 * * * * node /scripts/diy_health_energy.js >> /scripts/logs/diy_health_energy.log 2>&1\n"
  printf "# 京东超市-大转盘\n3 10 * * node /scripts/diy_marketLottery.js >> /scripts/logs/diy_marketLottery.log 2>&1\n"
  printf "# 母婴跳一跳\n5 8,14,20 * 4 * node /scripts/diy_mother_jump.js >> /scripts/logs/diy_mother_jump.log 2>&1\n"
  printf "# 超级摇一摇\n3 20 * * * node /scripts/diy_shake.js >> /scripts/logs/diy_shake.log 2>&1\n"
  printf "# 5G超级盲盒\n5 1,6,11,16,21 * 3-4 * node /scripts/diy_super5g.js >> /scripts/logs/diy_super5g.log 2>&1\n"
  printf "# 京东小魔方\n10 10 * 4 * node /scripts/diy_xmf.js >> /scripts/logs/diy_xmf.log 2>&1\n"
  printf "# interCenter渠道店铺签到\n0 0 * * * node /scripts/diy_inter_shop_sign.js >> /scripts/logs/diy_inter_shop_sign.log 2>&1\n"
  printf "# 有机牧场\n0 0,1-22/2 1-31 4-7 * node /scripts/diy_pasture.js >> /scripts/logs/diy_pasture.log 2>&1\n"
  printf "# 店铺加购有礼\n15 12 * * * node /scripts/diy_shop_add_to_car.js >> /scripts/logs/diy_shop_add_to_car.log 2>&1\n"
  printf "# 店铺关注有礼\n15 15 * * * node /scripts/diy_shop_follow_sku.js >> /scripts/logs/diy_shop_follow_sku.log 2>&1\n"
  printf "# 店铺大转盘\n3 0,10,23 * * * node /scripts/diy_shop_lottery.js >> /scripts/logs/diy_shop_lottery.log 2>&1\n"
  printf "# TCLxLINING\n25 8 * 4-5 * node /scripts/diy_tcl_lining.js >> /scripts/logs/diy_tcl_lining.log 2>&1\n"
  printf "# Vinda-维达品牌日\n15 08 5-30 4 * node /scripts/diy_vinda.js >> /scripts/logs/diy_vinda.log 2>&1\n"
  printf "# 半点京豆雨\n30 20-23/1 * * * node /scripts/diy_half_redrain.js >> /scripts/logs/diy_half_redrain.log 2>&1\n"
  printf "# 整点京豆雨\n1 0-23/1 * * * node /scripts/diy_super_redrain.js >> /scripts/logs/diy_super_redrain.log 2>&1\n"
  printf "# 东东超市\n59,29 23,0 * * * sleep 57; node /scripts/jd_blueCoin.js >> /scripts/logs/jd_blueCoin.log 2>&1\n"
  printf "# 京东汽车兑换\n0,1,3,59 23,0 * * * sleep 57; node /scripts/jd_car.js >> /scripts/logs/jd_car.log 2>&1\n"
} >> /scripts/docker/merged_list_file.sh
