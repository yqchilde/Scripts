version: "3"
services:
{{- range $idx := Iterate .Number }}
  jd_scripts{{$idx}}:
    image: lxk0301/jd_scripts:latest
    container_name: jd_scripts{{$idx}}
    restart: always
    volumes:
      - ./logs{{$idx}}:/scripts/logs
    tty: true
    extra_hosts:
      - "gitee.com:180.97.125.228"
      - "github.com:52.74.223.119"
      - "raw.githubusercontent.com:199.232.96.133"
    environment:
      - REPO_URL=git@gitee.com:lxk0301/jd_scripts.git

      # 京东Cookie
      - JD_COOKIE=${JD_COOKIE{{$idx}}}

      # 企业微信应用消息推送
      - QYWX_AM=${QYWX_AM{{$idx}}}

      {{- range $shareCode, $activeName := $.Actives }}

      # {{ $activeName }}
      - {{ $shareCode }}=${ {{- $shareCode -}}{{ $idx }}}

      {{- end }}

      # 宠汪汪喂食数量
      - JOY_FEED_COUNT=80

      # 宠汪汪兑换京豆数量
      - JD_JOY_REWARD_NAME=500

      # 东东超市
      - MARKET_COIN_TO_BEANS=维他奶

      # 京东领现金红包兑换京豆开关
      - CASH_EXCHANGE=false

      #使用自定义定任务追加默认任务之后
      - CUSTOM_SHELL_FILE=https://gitee.com/yqchilde/Scripts/raw/main/jd/jd_script.sh

      # 不执行的脚本
      - DO_NOT_RUN_SCRIPTS=jd_family

      # 取关店铺数量
      - UN_SUBSCRIBES=100&100
{{ end }}
