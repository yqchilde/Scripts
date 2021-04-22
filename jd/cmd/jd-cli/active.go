package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"sort"
	"strconv"
	"strings"
	"text/template"
	"time"

	"github.com/mdp/qrterminal/v3"
	"github.com/yqchilde/Doraemon/ghttp"

	"jd_scripts/internal"
)

const (
	SelectTypeGenerateDockerCompose = iota
	SelectTypeGenerateDotEnvFile
	SelectTypeQrScanLogin
	SelectTypeQuerySelfShareCode
	SelectTypeFormatFriendShareCode
)

var activitiesMap = map[string]string{
	"FRUITSHARECODES":           "东东农场",
	"PETSHARECODES":             "东东萌宠",
	"PLANT_BEAN_SHARECODES":     "种豆得豆",
	"DDFACTORY_SHARECODES":      "东东工厂",
	"DREAM_FACTORY_SHARE_CODES": "京喜工厂",
	"JXNC_SHARECODES":           "京喜农场",
	"JDZZ_SHARECODES":           "京东赚赚",
	"JDJOY_SHARECODES":          "crazyJoy",
	"JDSGMH_SHARECODES":         "闪购盲盒",
	"JDCFD_SHARECODES":          "财富岛",
	"JD_CASH_SHARECODES":        "签到领现金",
	"JDGLOBAL_SHARECODES":       "环球挑战赛",
	"BOOKSHOP_SHARECODES":       "口袋书店",
}

const (
	dockerComposeFilePath = "docker-compose.yml"
	shareCodeFilePath     = "shareCode.txt"
	dotEnvFilePath        = ".env"
)

var iterate = template.FuncMap{
	"Iterate": func(count int) []uint {
		var i uint
		var Items []uint
		for i = 1; i <= uint(count); i++ {
			Items = append(Items, i)
		}
		return Items
	},
}

// QuerySelfShareCode 查询当前日志中所有的助力码(按照docker-compose.yml文件中顺序)
func QuerySelfShareCode(paths []string) {
	if len(paths) == 0 {
		internal.Warning("在程序运行目录全局搜索没有发现sharecodeCollection.log文件")
		return
	}

	var (
		newLines         []string
		oldLines         []string
		findDividingLine = false
		infos            = make(map[string]string, len(activitiesMap))
	)

	for _, path := range paths {
		if file, err := os.Open(path); err != nil {
			panic(err)
		} else {
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				// 收集账号信息
				if internal.GetBetweenStr(scanner.Text(), "【京东账号 1 （", "）") != "" {
					infos["USERNAME"] = internal.GetBetweenStr(scanner.Text(), "【京东账号 1 （", "）")
				}

				// 收集活动信息
				for shareCode, activeName := range activitiesMap {
					if strings.Contains(scanner.Text(), "【京东账号 1 （") && strings.Contains(scanner.Text(), activeName) {
						infos[shareCode] = strings.ReplaceAll(scanner.Text(), " ", "")
					}
				}
			}

			internal.Info("\n京东账号" + "：" + infos["USERNAME"])
			newLines = append(newLines, "京东账号"+"："+infos["USERNAME"])

			mk := internal.GetKeys(activitiesMap)
			sort.Strings(mk)
			for _, k := range mk {
				if _, has := infos[k]; has {
					fmt.Println(infos[k])
					newLines = append(newLines, infos[k])
					delete(infos, k)
				} else {
					fmt.Println("【京东账号1（" + infos["USERNAME"] + "）" + activitiesMap[k] + "好友互助码】未获取到助力码，可能是该项目黑了")
					newLines = append(newLines, "【京东账号1（"+infos["USERNAME"]+"）"+activitiesMap[k]+"好友互助码】未获取到助力码，可能是该项目黑了")
				}
			}

			newLines = append(newLines, "")

			_ = file.Close()
		}
	}

	// 写入自己的助力码
	f, err := os.OpenFile(shareCodeFilePath, os.O_RDWR|os.O_CREATE, 0644)
	if err != nil {
		internal.CheckIfError(err)
	}
	defer f.Close()

	newLines = append(newLines, "# --------------------------------(助力码分割线，上面是自己，下面是其他人，用于自动化生成，误删)-------------------------------")

	// 判断当前是否存在shareCode文件且不是第一次存在
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		oldLines = append(oldLines, scanner.Text())
		if strings.Contains(scanner.Text(), "助力码分割线") {
			findDividingLine = true
		}
	}

	if findDividingLine {
		for i, line := range oldLines {
			if strings.Contains(line, "助力码分割线") {
				oldLines = oldLines[i+1:]
				newLines = append(newLines, oldLines...)
				output := strings.Join(newLines, "\n")
				if err = ioutil.WriteFile(shareCodeFilePath, []byte(output), 0644); err != nil {
					internal.CheckIfError(err)
				} else {
					internal.Info("\n数据成功写入 %s 文件", shareCodeFilePath)
				}
			}
		}
	} else {
		output := strings.Join(newLines, "\n")
		if err = ioutil.WriteFile(shareCodeFilePath, []byte(output), 0644); err != nil {
			internal.CheckIfError(err)
		} else {
			internal.Info("\n数据成功写入 %s 文件", shareCodeFilePath)
		}
	}
}

// SearchShareCodeCollectionFilePaths 搜索shareCodeCollection.log路径
func SearchShareCodeCollectionFilePaths() []string {
	var shareCodeFilePaths []string

	if file, err := os.Open(dockerComposeFilePath); err != nil {
		internal.CheckIfError(err)
	} else {
		defer file.Close()
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			if strings.Contains(scanner.Text(), ":/scripts/logs") {
				shareCodeFilePaths = append(shareCodeFilePaths, internal.GetBetweenStr(scanner.Text(), "- ", ":/scripts/logs")+"/sharecodeCollection.log")
			}
		}
	}

	return shareCodeFilePaths
}

// FormatFriendShareCode 格式化写入好友助力码到 .env
func FormatFriendShareCode() {
	if !internal.CheckFileExists(shareCodeFilePath) {
		internal.Warning(shareCodeFilePath + " 文件不存在")
		return
	}

	var (
		infos       = make(map[string]string, 30)
		cnt         = 1
		writeString []string
	)

	if file, err := os.Open(shareCodeFilePath); err != nil {
		internal.CheckIfError(err)
	} else {
		defer file.Close()
		scanner := bufio.NewScanner(file)
		for scanner.Scan() {
			// 整理互动信息
			for shareCode, activeName := range activitiesMap {
				if strings.Contains(scanner.Text(), activeName) {
					if _, has := infos[shareCode+strconv.Itoa(cnt)]; has {
						infos[shareCode+strconv.Itoa(cnt)] = scanner.Text()[strings.Index(scanner.Text(), "】")+len("】"):]
						cnt += 1
					} else {
						infos[shareCode+strconv.Itoa(cnt)] = scanner.Text()[strings.Index(scanner.Text(), "】")+len("】"):]
					}
				}
			}

			// 整理账号信息
			if internal.GetBetweenStr(scanner.Text(), "京东账号：", "") != "" {
				if _, has := infos["USERNAME"+strconv.Itoa(cnt)]; has {
					infos["USERNAME"+strconv.Itoa(cnt+1)] = internal.GetBetweenStr(scanner.Text(), "京东账号：", "")
					cnt += 1
				} else {
					infos["USERNAME"+strconv.Itoa(cnt)] = internal.GetBetweenStr(scanner.Text(), "京东账号：", "")
				}
			}
		}

		writeString = append(writeString, "\n# 助力码顺序（推荐按照docker-compose多容器配置顺序整理 friend_code.txt 并生成）")

		for i := 0; i < cnt; i++ {
			writeString = append(writeString, "# 助力码"+strconv.Itoa(i+1)+"="+infos["USERNAME"+strconv.Itoa(i+1)])
		}

		mk := internal.GetKeys(activitiesMap)
		sort.Strings(mk)
		for _, k := range mk {
			writeString = append(writeString, "\n# "+activitiesMap[k])
			shareCodeShort := processingShareCodeName(k)

			for i := 0; i < cnt; i++ {
				if _, has := infos[k+strconv.Itoa(i+1)]; has {
					writeString = append(writeString, shareCodeShort+strconv.Itoa(i+1)+"="+infos[k+strconv.Itoa(i+1)])
				} else {
					writeString = append(writeString, shareCodeShort+strconv.Itoa(i+1)+"="+"没有助力码，请检查friend_code.txt文件")
				}
			}

			// 格式化
			writeString = append(writeString, "")
			for i := 0; i < len(SearchShareCodeCollectionFilePaths()); i++ {
				writeString = append(writeString, k+strconv.Itoa(i+1)+"="+singleHandle(infos, cnt, i+1, k))
			}
		}
	}

	// 写入 .env
	input, err := ioutil.ReadFile(dotEnvFilePath)
	if err != nil {
		internal.CheckIfError(err)
	}

	var (
		lines        = strings.Split(string(input), "\n")
		newLines     []string
		findNextLine = false
	)

	for _, line := range lines {
		if findNextLine {
			break
		}
		newLines = append(newLines, line)

		if strings.Contains(line, "助力码分割线") {
			findNextLine = true
			continue
		}
	}

	newLines = append(newLines, writeString...)
	output := strings.Join(newLines, "\n")
	if err = ioutil.WriteFile(dotEnvFilePath, []byte(output), 0644); err != nil {
		internal.CheckIfError(err)
	} else {
		internal.Info("数据成功写入 %s 文件", dotEnvFilePath)
	}
}

// JDLoginByQrScan JD扫码登录
func JDLoginByQrScan() {
	nowTimeStamp := strconv.FormatInt(time.Now().UnixNano()/1e6, 10)

	// Step1 获取Cookie
	url := "https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport"
	headers := map[string]string{
		"Connection":      "Keep-Alive",
		"Content-Type":    "application/x-www-form-urlencoded",
		"Accept":          "application/json, text/plain, */*",
		"Accept-Language": "zh-cn",
		"Referer":         "https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport",
		"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36",
		"Host":            "plogin.m.jd.com",
	}

	resp := ghttp.Get(url).AddHeaders(headers).Do()

	sTokenStruct := struct {
		SToken string `json:"s_token"`
	}{}

	err := resp.BindJSON(&sTokenStruct)
	if err != nil {
		internal.Warning("JDLoginByQrScan.Step1 bind json failed, err: %s", err.Error())
		return
	}

	sToken := sTokenStruct.SToken
	guid := resp.Cookies()[0].Value
	lsid := resp.Cookies()[2].Value
	lsToken := resp.Cookies()[3].Value
	cookies := "guid=" + guid + "; lang=chs; lsid=" + lsid + "; lstoken=" + lsToken + "; "

	// Step2 拿到二维码链接
	url = "https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=" + sToken + "&v=" + nowTimeStamp + "&remember=true"
	form := map[string]string{
		"lang":      "chs",
		"appid":     "300",
		"source":    "wq_password",
		"returnurl": "https://wqlogin2.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action",
	}
	headers = map[string]string{
		"Connection":      "Keep-Alive",
		"Content-Type":    "application/x-www-form-urlencoded",
		"Accept":          "application/json, text/plain, */*",
		"Accept-Language": "zh-cn",
		"Referer":         "https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport",
		"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36",
		"Host":            "plogin.m.jd.com",
		"Cookie":          cookies,
	}
	resp = ghttp.Post(url).SetFormBody(form).AddHeaders(headers).Do()

	mTokenStruct := struct {
		Token string `json:"token"`
	}{}

	err = resp.BindJSON(&mTokenStruct)
	if err != nil {
		internal.Warning("JDLoginByQrScan.Step2 bind json failed, err: %s", err.Error())
		return
	}

	oklToken := resp.Cookies()[0].Value

	// Step3 生成二维码
	qrUrl := "https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=" + mTokenStruct.Token
	config := qrterminal.Config{
		Level:     qrterminal.L,
		Writer:    os.Stdout,
		BlackChar: qrterminal.BLACK,
		WhiteChar: qrterminal.WHITE,
		QuietZone: 4,
	}

	qrterminal.GenerateWithConfig(qrUrl, config)

	// Step4 验证扫码
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case _ = <-ticker.C:
			url := "https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?token=" + mTokenStruct.Token + "&ou_state=0&okl_token=" + oklToken
			form := map[string]string{
				"lang":      "chs",
				"appid":     "300",
				"source":    "wp_passport",
				"returnurl": "https://wqlogin2.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action",
			}
			headers := map[string]string{
				"Connection":   "Keep-Alive",
				"Content-Type": "application/x-www-form-urlencoded; Charset=UTF-8",
				"Accept":       "application/json, text/plain, */*",
				"User-Agent":   "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36",
				"Referer":      "https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=" + nowTimeStamp + "&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport",
				"Cookie":       cookies,
			}

			resp := ghttp.Post(url).SetFormBody(form).AddHeaders(headers).Do()

			qrScanRes := struct {
				Errcode uint8  `json:"errcode"`
				Message string `json:"message"`
			}{}

			err = resp.BindJSON(&qrScanRes)
			if err != nil {
				internal.Warning("JDLoginByQrScan.Step4 bind json failed, err: %s", err.Error())
				return
			}

			switch qrScanRes.Errcode {
			case 0:
				internal.Info("\nCookie如下：\n")
				ptKey := resp.Cookies()[1].Value
				ptPin := resp.Cookies()[2].Value
				jdCookie := "pt_key=" + ptKey + ";pt_pin=" + ptPin + ";"
				internal.Info(jdCookie)

				// 自动替换到docker-compose.yml
				// Condition1 不存在日志的，按顺序添加cookie

				// Condition2 已存在日志的，根据日志中的账号位置自动替换对应cookie
				jdUserNames := QueryJDNameByDockerCompose(SearchShareCodeCollectionFilePaths())
				if len(jdUserNames) == 0 {
					// 写入env
					input, err := ioutil.ReadFile(dotEnvFilePath)
					if err != nil {
						internal.CheckIfError(err)
					}

					lines := strings.Split(string(input), "\n")

					lineIdx, ckIdx := 0, 0
					for j, line := range lines {
						line = strings.TrimSpace(line)

						if strings.Contains(line, "JD_COOKIE") {
							ckIdx, _ = strconv.Atoi(internal.GetBetweenStr(line, "JD_COOKIE", "="))
							if len(line[len("JD_COOKIE"+strconv.Itoa(ckIdx)+"="):]) == 0 {
								lines[j] = "JD_COOKIE" + strconv.Itoa(ckIdx) + "=" + jdCookie
							} else {
								lineIdx = j
							}
						}
					}

					if lineIdx != 0 {
						lines = append(lines, "")
						copy(lines[lineIdx+1:], lines[lineIdx:])
						lines[lineIdx+1] = "JD_COOKIE" + strconv.Itoa(ckIdx+1) + "=" + jdCookie
					}

					output := strings.Join(lines, "\n")

					if err = ioutil.WriteFile(dotEnvFilePath, []byte(output), 0644); err != nil {
						internal.CheckIfError(err)
					} else {
						internal.Info("该账号的Cookie已自动写入到 .env 配置文件中")
					}
				} else {
					for i := range jdUserNames {
						if jdUserNames[i] == ptPin {
							for i := range jdUserNames {
								if jdUserNames[i] == ptPin {
									// 写入env
									input, err := ioutil.ReadFile(dotEnvFilePath)
									if err != nil {
										internal.CheckIfError(err)
									}

									lines := strings.Split(string(input), "\n")

									for j, line := range lines {
										if strings.Contains(line, "JD_COOKIE"+strconv.Itoa(i+1)+"=") {
											lines[j] = "JD_COOKIE" + strconv.Itoa(i+1) + "=" + jdCookie
										}
									}
									output := strings.Join(lines, "\n")

									if err = ioutil.WriteFile(dotEnvFilePath, []byte(output), 0644); err != nil {
										internal.CheckIfError(err)
									} else {
										internal.Info("该账号的Cookie已自动写入到 .env 配置文件中")
									}
								}
							}
							return
						}
					}
				}
				return
			case 21:
				internal.Warning("二维码失效")
				return
			case 176:
			default:
				// 其他异常
				internal.Warning("errcode: %d, message: %s", qrScanRes.Errcode, qrScanRes.Message)
				return
			}
		}
	}
}

// QueryJDNameByDockerCompose 通过docker-compose.yml文件按顺序查询用户名
func QueryJDNameByDockerCompose(paths []string) []string {
	var ret []string
	for _, path := range paths {
		if file, err := os.Open(path); err != nil {
			return nil
		} else {
			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				// 从账号1 start
				if internal.GetBetweenStr(scanner.Text(), "【京东账号 1 （", "）") != "" {
					ret = append(ret, internal.GetBetweenStr(scanner.Text(), "【京东账号 1 （", "）"))
					break
				}
			}
			_ = file.Close()
		}
	}

	return ret
}

// DockerComposeTemplate docker-compose.yml文件模板
func DockerComposeTemplate() string {
	return `version: "3"
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

      # 企业微信机器人通知
      - QYWX_AM=${CORPID},${CORPSECRET},${TOUSER},${AGENTID},${MEDIAID}

	  {{- range $shareCode, $activeName := $.Actives }}

	  # {{ $activeName }}
	  - {{ $shareCode }}=${ {{- $shareCode -}}{{ $idx }}}

	  {{- end }}

      # 宠汪汪喂食数量
      - JOY_FEED_COUNT=80

      # 宠汪汪兑换京豆数量
      - JD_JOY_REWARD_NAME=500

      # 东东超市
      - MARKET_COIN_TO_BEANS=纯甄

      #使用自定义定任务追加默认任务之后
      - CUSTOM_SHELL_FILE=https://gitee.com/yqchilde/Scripts/raw/main/jd/jd_script.sh

      # 不执行的脚本
      - DO_NOT_RUN_SCRIPTS=jd_family

      # 取关店铺数量
      - UN_SUBSCRIBES=100&100
{{ end }}
`
}

// GenerateDockerComposeTemplate 生成docker-compose.yml
func GenerateDockerComposeTemplate(num int) {
	var buf bytes.Buffer

	composeTemplate := struct {
		Number  int
		Actives map[string]string
	}{
		Number:  num,
		Actives: activitiesMap,
	}

	parse, err := template.New("docker-compose").Funcs(iterate).Parse(DockerComposeTemplate())
	if err != nil {
		internal.CheckIfError(err)
	}

	if err = parse.Execute(&buf, &composeTemplate); err != nil {
		internal.CheckIfError(err)
	}

	// 检查当前目录是否有 docker-compose.yml
	exists := internal.CheckFileExists(dockerComposeFilePath)
	if exists {
		internal.Info("发现当前目录存在 %s 文件，故先备份文件为 %s", dockerComposeFilePath, dockerComposeFilePath+".bak")
		err := os.Rename(dockerComposeFilePath, dockerComposeFilePath+".bak")
		internal.CheckIfError(err)
	}

	if err := ioutil.WriteFile(dockerComposeFilePath, buf.Bytes(), 0644); err != nil {
		internal.CheckIfError(err)
	} else {
		internal.Info("成功生成 %s 文件", dockerComposeFilePath)
	}
}

// DotEnvFileTemplate .env 配置文件模板
func DotEnvFileTemplate() string {
	return `# -------------------------------------------(推送分割线，用于自动化生成，误删)-------------------------------------------
# 企业微信
CORPID=
CORPSECRET=
TOUSER=
AGENTID=
MEDIAID=

# ------------------------------------------(Cookie分割线，用于自动化生成，误删)------------------------------------------

{{ range $idx := Iterate . -}}
JD_COOKIE{{$idx}}=
{{ end }}
# -------------------------------------------(助力码分割线，用于自动化生成，误删)------------------------------------------`
}

// GenerateDotEnvFile 生成 .env 配置文件
func GenerateDotEnvFile() {
	// 检查当前目录是否有 .env
	exists := internal.CheckFileExists(dotEnvFilePath)
	if exists {
		internal.Info("发现当前目录存在 %s 文件，故先备份文件为 %s", dotEnvFilePath, dotEnvFilePath+".bak")
		err := os.Rename(dotEnvFilePath, dotEnvFilePath+".bak")
		internal.CheckIfError(err)
	}

	var buf bytes.Buffer
	t := template.Must(template.New("generate_env").Funcs(iterate).Parse(DotEnvFileTemplate()))
	err := t.Execute(&buf, len(SearchShareCodeCollectionFilePaths()))
	internal.CheckIfError(err)

	if err := ioutil.WriteFile(dotEnvFilePath, buf.Bytes(), 0644); err != nil {
		internal.CheckIfError(err)
	} else {
		internal.Info("成功生成 %s 文件", dotEnvFilePath)
	}
}

func processingShareCodeName(shareCode string) string {
	var shareCodeShort string

	if strings.Contains(shareCode, "_SHARE_CODES") {
		shareCodeShort = shareCode[:strings.Index(shareCode, "_SHARE_CODES")]
	} else if strings.Contains(shareCode, "_SHARECODES") {
		shareCodeShort = shareCode[:strings.Index(shareCode, "_SHARECODES")]
	} else if strings.Contains(shareCode, "SHARECODES") {
		shareCodeShort = shareCode[:strings.Index(shareCode, "SHARECODES")]
	}

	return shareCodeShort
}

func singleHandle(infos map[string]string, cnt, idx int, shareCode string) string {
	ret := ""

	shareCodeShort := processingShareCodeName(shareCode)

	for i := 1; i < cnt+1; i++ {
		if idx == i {
			continue
		} else if _, has := infos[shareCode+strconv.Itoa(i)]; !has {
			continue
		} else if internal.IsHan(infos[shareCode+strconv.Itoa(i)][:3]) {
			continue
		} else {
			ret += "${" + shareCodeShort + strconv.Itoa(i) + "}@"
		}
	}

	if len(ret) > 0 {
		return ret[:len(ret)-1]
	}
	return ret
}
