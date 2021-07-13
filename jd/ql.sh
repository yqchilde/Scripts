#!/usr/bin/env bash

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/api.sh
dir_scripts=/ql/scripts

echo "⚠️ 该文件已失效，即将进行替换以下命令"
echo '/bin/bash -c "$(curl -fsSL https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh)"'
sed -i -e 's/curl https:\/\/gitee.com\/yqchilde\/Scripts\/raw\/main\/jd\/ql.sh | bash/\/bin\/bash -c "$(curl -fsSL https:\/\/gitee.com\/yqchilde\/Scripts\/raw\/main\/jd\/extra.sh)"/g' /ql/config/extra.sh
echo '😊 已成功替换命令为\n/bin/bash -c "$(curl -fsSL https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh)"\n\n🙆‍♂️可忽略本次通知'
notify '自定义脚本extra.sh命令替换通知' '😊 已成功替换命令为\n/bin/bash -c "$(curl -fsSL https://gitee.com/yqchilde/Scripts/raw/main/jd/extra.sh)"\n\n🙆‍♂️可忽略本次通知'