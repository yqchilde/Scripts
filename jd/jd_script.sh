#!/bin/bash

mergedListFile="/scripts/docker/merged_list_file.sh"

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
  printf "# 手机狂欢城\n2 0-18/6 * 5 * node /scripts/diy_carnivalcity.js >> /scripts/logs/diy_carnivalcity.log 2>&1\n"
  printf "# 粉丝互动\n3 10 * * * node /scripts/diy_fanslove.js >> /scripts/logs/diy_fanslove.log 2>&1\n"
  printf "# 健康社区\n25 10-22/3 * * * node /scripts/diy_health_community.js >> /scripts/logs/diy_health_community.log 2>&1\n"
  printf "# 京东超市-大转盘\n3 10 * * * node /scripts/diy_marketLottery.js >> /scripts/logs/diy_marketLottery.log 2>&1\n"
  printf "# 超级无线组队分京豆\n25 3 * * 2 node /scripts/diy_shop_captain.js >> /scripts/logs/diy_shop_captain.log 2>&1\n"
  printf "# 飞利浦电视成长记\n15 9 * 5,6 * node /scripts/diy_adolf_flp.js >> /scripts/logs/diy_adolf_flp.log 2>&1\n"
  printf "# 京喜阶梯红包\n15 9 * 5,6 * node /scripts/diy_adolf_jxhb.js >> /scripts/logs/diy_adolf_jxhb.log 2>&1\n"
  printf "# 人头马x博朗\n20 9 20-31 5 * node /scripts/diy_adolf_martin.js >> /scripts/logs/diy_adolf_martin.log 2>&1\n"
  printf "# 618大势新品赏\n15 9,20 * 5,6 * node /scripts/diy_adolf_newInteraction.js >> /scripts/logs/diy_adolf_newInteraction.log 2>&1\n"
  printf "# 赢一加新品手机\n25 9 * 5,6 * node /scripts/diy_adolf_oneplus.js >> /scripts/logs/diy_adolf_oneplus.log 2>&1\n"
  printf "# 京享值PK\n15 8,13,18 17-31 5 * node /scripts/diy_adolf_pk.js >> /scripts/logs/diy_adolf_pk.log 2>&1\n"
  printf "# 家电星推官\n40 9-18/3 * 5,6 * node /scripts/diy_adolf_star.js >> /scripts/logs/diy_adolf_star.log 2>&1\n"
  printf "# 京东超级盒子\n15 9,20 * 5,6 * node /scripts/diy_adolf_superbox.js >> /scripts/logs/diy_adolf_superbox.log 2>&1\n"
  printf "# 坐等更新\n28 9 * 5 * node /scripts/diy_adolf_urge.js >> /scripts/logs/diy_adolf_urge.log 2>&1\n"
  printf "# 有机牧场\n0 0,1-22/2 1-31 4-7 * node /scripts/diy_pasture.js >> /scripts/logs/diy_pasture.log 2>&1\n"
  printf "# 店铺加购有礼\n15 12 * * * node /scripts/diy_shop_add_to_car.js >> /scripts/logs/diy_shop_add_to_car.log 2>&1\n"
  printf "# 店铺关注有礼\n15 15 * * * node /scripts/diy_shop_follow_sku.js >> /scripts/logs/diy_shop_follow_sku.log 2>&1\n"
  printf "# 店铺大转盘\n3 0,10,23 * * * node /scripts/diy_shop_lottery.js >> /scripts/logs/diy_shop_lottery.log 2>&1\n"
  printf "# 京东星店长\n5 9 * * * node /scripts/diy_starStore.js >> /scripts/logs/diy_starStore.log 2>&1\n"
  printf "# 半点京豆雨\n30 16-23/1 * * * node /scripts/diy_half_redrain.js >> /scripts/logs/diy_half_redrain.log 2>&1\n"
  printf "# 618主会场红包雨\n1 20 1-18 6 * node /scripts/diy_hby_lottery.js >> /scripts/logs/diy_hby_lottery.log 2>&1\n"
  printf "# 整点京豆雨\n1 0-23/1 * * * node /scripts/diy_super_redrain.js >> /scripts/logs/diy_super_redrain.log 2>&1\n"
  printf "# 京东资产变动通知\n0 9 * * * node /scripts/diy_all_bean_change.js >> /scripts/logs/diy_all_bean_change.log 2>&1\n"
  printf "# 总裁送好礼\n30 9,10 * * * node /scripts/diy_babelDiy.js >> /scripts/logs/diy_babelDiy.log 2>&1\n"
  printf "# 宝洁消消乐\n18 9 1-18 6 * node /scripts/diy_zooBaojiexiaoxiaole.js >> /scripts/logs/diy_zooBaojiexiaoxiaole.log 2>&1\n"
  printf "# 新潮品牌狂欢\n15 9 1-18 6 * node /scripts/diy_zooBrandcity.js >> /scripts/logs/diy_zooBrandcity.log 2>&1\n"
  printf "# 限时盲盒\n15 12 1-18 6 * node /scripts/diy_zooLimitbox.js >> /scripts/logs/diy_zooLimitbox.log 2>&1\n"
  printf "# 与'粽'不同\n15 13 1-18 6 * node /scripts/diy_zooLongzhou.js >> /scripts/logs/diy_zooLongzhou.log 2>&1\n"
  printf "# 东东超市\n59,29 23,0 * * * sleep 57; node /scripts/jd_blueCoin.js >> /scripts/logs/jd_blueCoin.log 2>&1\n"
  printf "# 京东汽车兑换\n0,1,3,59 23,0 * * * sleep 57; node /scripts/jd_car.js >> /scripts/logs/jd_car.log 2>&1\n"
} >>${mergedListFile}

# 修改定时任务
sed -i 's/^0,30 0 \* \* \* node \/scripts\/jd_blueCoin.js/#&/' ${mergedListFile}
sed -i 's/^0 0 \* \* \* node \/scripts\/jd_car.js/#&/' ${mergedListFile}
sed -i 's/^1,31 0-23\/1 \* \* \* node \/scripts\/jd_live_redrain.js/#&/' ${mergedListFile}
sed -i 's/^20 10 \* \* \* node \/scripts\/jd_bean_change.js/#&/' ${mergedListFile}
