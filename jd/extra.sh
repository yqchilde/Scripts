#!/usr/bin/env bash

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/api.sh
dir_scripts=/ql/scripts

echo "🏃 是时候说再见了！！！"
sed -i -e 's/\/bin\/bash -c "$(curl -fsSL https:\/\/gitee.com\/yqchilde\/Scripts\/raw\/main\/jd\/extra.sh)"/""/g' /ql/config/extra.sh
notify '🏃 是时候说再见了！！！' '不知道还有多少朋友在用我的这个脚本，很抱歉的要说一声再见了，目前该脚本我已无心维护了(玩够了)，祝大家玩得开心，希望我们有缘可以在我的退会脚本中相遇。'