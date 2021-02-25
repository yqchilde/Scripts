#!/bin/bash

docker-compose down
docker rmi lxk0301/jd_scripts
docker-compose up -d

wget https://raw.sevencdn.com/yqchilde/Scripts/main/node/jd/joy_reword.js -O ./joy_reword.js
docker cp ./joy_reword.js jd_scripts:/scripts/joy_reword.js

# 华硕-爱奇艺
wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_asus_iqiyi.js -O ./jd_asus_iqiyi.js
docker cp ./jd_asus_iqiyi.js jd_scripts:/scripts/jd_asus_iqiyi.js

# 跳一跳
wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_jump-jump.js -O ./jd_jump-jump.js
docker cp ./jd_jump-jump.js jd_scripts:/scripts/jd_jump-jump.js

# 百变大咖秀
wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_entertainment.js -O ./jd_entertainment.js
docker cp ./jd_entertainment.js jd_scripts:/scripts/jd_entertainment.js

# 粉丝互动
wget https://raw.sevencdn.com/i-chenzhe/qx/main/jd_fanslove.js -O ./jd_fanslove.js
docker cp ./jd_fanslove.js jd_scripts:/scripts/jd_fanslove.js

# 财富岛任务
wget https://raw.sevencdn.com/moposmall/Script/main/Me/jx_cfd.js -O ./jx_cfd.js
docker cp ./jx_cfd.js jd_scripts:/scripts/jx_cfd.js

# 财富岛通知
wget https://raw.sevencdn.com/moposmall/Script/main/Me/jx_cfd_exchange.js -O ./jx_cfd_exchange.js
docker cp ./jx_cfd_exchange.js jd_scripts:/scripts/jx_cfd_exchange.js

# 格式化互助码
wget https://gitee.com/qq34347476/quantumult-x/raw/master/format_share_jd_code.js -O ./format_share_jd_code.js
docker cp ./format_share_jd_code.js jd_scripts:/scripts/format_share_jd_code.js

rm -rf *.js

