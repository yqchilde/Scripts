# 兑换500豆子
3,6,9 0 8,16 * * * node /scripts/joy_reward.js >> /scripts/logs/joy_reward.log 2>&1

# 母婴-跳一跳
5 8,14,20 2-7 3 * node /scripts/jd_jump-jump.js >> /scripts/logs/jd_jump-jump.log 2>&1

# 百变大咖秀
10 10,11 * * 2-5 node /scripts/jd_entertainment.js >> /scripts/logs/jd_entertainment.log 2>&1

# 粉丝互动
3 10 * * * node /scripts/jd_fanslove.js >> /scripts/jd_fanslove.log 2>&1

# 财富岛通知
30 6,12,22 * * * node /scripts/jx_cfd_exchange.js >> /scripts/logs/jx_cfd_exchange.log 2>&1

# 摇一摇活动
3 20 * * * node /scripts/jd_shake.js >> /scripts/logs/jd_shake.log 2>&1

# 财富岛提现
0 0 * * * node /scripts/jx_cfdtx.js >> /scripts/logs/jx_cfdtx.log 2>&1

# 红包雨
30,31 20-23/1 2,5 3 * node /scripts/jd_live_redrain.js >> /scripts/logs/jd_live_redrain.log 2>&1

# 格式化互助码
0 1 0/2 * * node /scripts/format_share_jd_code.js >> /scripts/logs/format_share_jd_code.log 2>&1
