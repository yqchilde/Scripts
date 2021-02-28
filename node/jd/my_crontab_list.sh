# 兑换500豆子
0 */3 * * * wget https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/author/lxk0301/joy_reword.js -O /scripts/joy_reword.js
3,6,9 0 8,16 * * * node /scripts/joy_reward.js >> /scripts/logs/joy_reward.log 2>&1

# 华硕-爱奇艺
1 */3 * * * wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_asus_iqiyi.js -O /scripts/jd_asus_iqiyi.js
0 0 22-28 2 * node /scripts/jd_asus_iqiyi.js >> /scripts/logs/jd_asus_iqiyi.log 2>&1

# 跳一跳
2 */3 * * * wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_jump-jump.js -O /scripts/jd_jump-jump.js
5 8,14,20 22-27 2 * node /scripts/jd_jump-jump.js >> /scripts/logs/jd_jump-jump.log 2>&1

# 百变大咖秀
3 */3 * * * wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_entertainment.js -O /scripts/jd_entertainment.js
10 10,11 * * 2-5 node /scripts/jd_entertainment.js >> /scripts/logs/jd_entertainment.log 2>&1

# 粉丝互动
4 */3 * * * wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_fanslove.js -O /scripts/jd_fanslove.js
3 10 * * * node /scripts/jd_fanslove.js >> /scripts/jd_fanslove.log 2>&1

# 财富岛通知
6 */3 * * * wget https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_cfd_exchange.js -O /scripts/jx_cfd_exchange.js
30 6,12,22 * * * node /scripts/jx_cfd_exchange.js >> /scripts/logs/jx_cfd_exchange.log 2>&1

# 摇一摇活动
7 */3 * * * wget https://raw.githubusercontent.com/i-chenzhe/qx/main/jd_shake.js -O /scripts/jd_shake.js
3 20 * * * node /scripts/jd_shake.js >> /scripts/logs/jd_shake.log 2>&1

# 财富岛提现
8 */3 * * * https://raw.githubusercontent.com/yqchilde/Scripts/main/node/jd/author/whyour/jx_cfdtx.js -O /scripts/jx_cfdtx.js
0 0 * * * node /scripts/jx_cfdtx.js >> /scripts/logs/jx_cfdtx.log 2>&1

# 格式化互助码
0 */12 * * * wget https://gitee.com/qq34347476/quantumult-x/raw/master/format_share_jd_code.js -O /scripts/format_share_jd_code.js
0 1 0/2 * * node /scripts/format_share_jd_code.js >> /scripts/logs/format_share_jd_code.log 2>&1
