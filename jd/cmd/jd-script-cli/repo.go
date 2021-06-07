package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"

	"jd_scripts/internal"
)

const (
	SelectTypePullGitRepo = iota
	SelectTypeSpiderOtherScript
	SelectTypeGenerateJdScriptShell
	SelectTypeScriptFileNameReverse
)

var gitAuthorList = []string{"zooPanda", "yangtingxiao", "longzhuzhu"}

var allAuthorList = []string{"i-chenzhe", "monk-coder", "yangtingxiao", "longzhuzhu", "lxk0301", "zooPanda"}

var gitAuthorRepoMap = map[string]string{
	"yangtingxiao": "https://github.com/yangtingxiao/QuantumultX.git",
	"longzhuzhu":   "https://github.com/longzhuzhu/nianyu.git",
	"i-chenzhe":    "https://github.com/monk-coder/dust.git",
	"monk-coder":   "https://github.com/monk-coder/dust.git",
	"zooPanda":     "https://github.com/zooPanda/zoo.git",
}

var gitRepoBranchMap = map[string]string{
	"longzhuzhu":   "main",
	"i-chenzhe":    "dust",
	"monk-coder":   "dust",
	"zooPanda":     "dev",
	"yangtingxiao": "master",
}

var gitAuthorPathMap = map[string][]string{
	"i-chenzhe":    {"i-chenzhe"},
	"monk-coder":   {"car", "member", "normal"},
	"yangtingxiao": {"scripts"},
	"longzhuzhu":   {"qx"},
	"zooPanda":     {"/"},
}

// 这里希望写入 [*(所有文件) | @脚本名字(过滤脚本) | 指定脚本名字] 三种方式
var gitAuthorScripts = map[string][]string{
	"i-chenzhe":    {"@z_getFanslove.js"},
	"monk-coder":   {"*"},
	"yangtingxiao": {"jd_starStore.js"},
	"longzhuzhu":   {"*"},
	"zooPanda":     {"@zooOpencard01.js", "@zooOpencard02.js", "@zooOpencard03.js", "@zooOpencard04.js", "@zooOpencard05.js"},
}

const (
	cronRegex   = `[^\s\:]((\*|[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}\/[0-9]{1,2}|([0-9]{1,2}\,?)*|([0-9]{1,2}\,?)*\-[0-9]{1,2}|([0-9]{1,2}\,?)*\-[0-9]{1,2}\/[0-9]{1,2})+[ ]){4}(\*|[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}\/[0-9]{1,2}|([0-9]{1,2}\,?)*|([0-9]{1,2}\,?)*\-[0-9]{1,2}|([0-9]{1,2}\,?)*\-[0-9]{1,2}\/[0-9]{1,2})`
	activeRegex = `(?m)new Env\(\"?\'?(.*?)\"?\'?\)`
)

func GetScriptTemplate() string {
	return `#!/bin/bash

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
  {{- range $_, $cron := .CronList}}
  {{ $cron -}}
  {{- end }}
  printf "# 东东超市\n59,29 23,0 * * * sleep 57; node /scripts/jd_blueCoin.js >> /scripts/logs/jd_blueCoin.log 2>&1\n"
  printf "# 京东汽车兑换\n0,1,3,59 23,0 * * * sleep 57; node /scripts/jd_car.js >> /scripts/logs/jd_car.log 2>&1\n"
} >>${mergedListFile}

# 修改定时任务
sed -i 's/^0,30 0 \* \* \* node \/scripts\/jd_blueCoin.js/#&/' ${mergedListFile}
sed -i 's/^0 0 \* \* \* node \/scripts\/jd_car.js/#&/' ${mergedListFile}
sed -i 's/^1,31 0-23\/1 \* \* \* node \/scripts\/jd_live_redrain.js/#&/' ${mergedListFile}
sed -i 's/^20 10 \* \* \* node \/scripts\/jd_bean_change.js/#&/' ${mergedListFile}
`
}

// GenerateJDScriptShell 生成jd_script.sh脚本
func GenerateJDScriptShell() {
	var cronList []string

	for _, author := range allAuthorList {
		internal.Info("遍历当前 %s 的脚本并生成对应的cron", author)
		currentScripts, _ := filepath.Glob("./scripts/author/" + author + "/*.js")
		for i := range currentScripts {
			_, fileName := filepath.Split(currentScripts[i])
			fileName = strings.ReplaceAll(fileName, ".js", "")
			cron, active := "", ""
			if file, err := os.Open(currentScripts[i]); err != nil {
				panic(err)
			} else {
				scanner := bufio.NewScanner(file)
				cronReg := regexp.MustCompile(cronRegex)
				activeReg := regexp.MustCompile(activeRegex)
				for scanner.Scan() {
					if cronReg.MatchString(scanner.Text()) {
						if cron == "" {
							cron = strings.Trim(cronReg.FindString(scanner.Text()), " ")
						}
					}
					if activeReg.MatchString(scanner.Text()) {
						if active == "" {
							active = strings.Trim(activeReg.FindStringSubmatch(scanner.Text())[1], " ")
						}
					}

					if cron != "" && active != "" {
						break
					}
				}
			}

			cronList = append(cronList, `printf "# `+active+`\n`+cron+` node /scripts/`+fileName+`.js >> /scripts/logs/`+fileName+`.log 2>&1\n"`)
		}
	}

	// 先写入文件然后覆盖
	if len(cronList) != 0 {
		internal.Info("重新写入jd_script.sh")
		type Cron struct {
			CronList []string
		}

		var buf bytes.Buffer
		cron := &Cron{CronList: cronList}
		t := template.Must(template.New("jd_script").Parse(GetScriptTemplate()))
		err := t.Execute(&buf, cron)
		if err != nil {
			internal.Warning("Executing template:", err)
		}

		if err = ioutil.WriteFile("./jd_script.sh", buf.Bytes(), 0644); err != nil {
			internal.CheckIfError(err)
		}
	}
}

// GitCloneRepo ...
func GitCloneRepo() {
	for _, author := range gitAuthorList {
		internal.Info("正在处理 %s 的脚本", author)

		hasGitPath := internal.CheckFileExists(author)
		if !hasGitPath {
			_, err := CloneScriptRepo(gitAuthorRepoMap[author], author, gitRepoBranchMap[author])
			internal.CheckIfError(err)
		} else {
			ret, err := PullScriptRepo(author)
			internal.CheckIfError(err)
			if strings.Contains(ret, "Already up to date") {
				internal.Warning("%s 的仓库没有更新，即将跳过", author)
				continue
			}
		}

		// 移除旧文件
		internal.Info("移除旧文件")
		err := internal.CopyDir("scripts/author/"+author, "scripts/backup/"+author)
		internal.CheckIfError(err)

		// 开始拷贝文件
		internal.Info("开始拷贝 %s 脚本", author)

		scriptPaths := gitAuthorPathMap[author]
		scriptFiles := gitAuthorScripts[author]
		var scriptFilePaths []string
		for i := range scriptPaths {
			if err := filepath.Walk(author+"/"+scriptPaths[i], func(path string, info os.FileInfo, err error) error {
				if len(scriptFiles) == 1 && scriptFiles[0] == "*" {
					if filepath.Ext(path) == ".js" {
						scriptFilePaths = append(scriptFilePaths, path)
					}
				} else if scriptFiles[0][0] == '@' {
					var isMatch bool
					for k := range scriptFiles {
						if scriptFiles[k][0] != '@' {
							internal.Warning("%s 的脚本过滤文件规则不一致", k)
							return nil
						}

						filterScriptName := scriptFiles[k][1:]
						if info.Name() == filterScriptName {
							isMatch = true
							break
						}
					}

					if !isMatch && filepath.Ext(path) == ".js" {
						scriptFilePaths = append(scriptFilePaths, path)
					}
				} else {
					for j := range scriptFiles {
						if info.Name() == scriptFiles[j] {
							fmt.Println(path)
							scriptFilePaths = append(scriptFilePaths, path)
						}
					}
				}
				return nil
			}); err != nil {
				internal.CheckIfError(err)
			}
		}

		// 将文件移到指定项目目录
		internal.Info("将 %s 脚本移到指定项目目录", author)
		for i := range scriptFilePaths {
			_, fileName := filepath.Split(scriptFilePaths[i])
			exists := internal.CheckFileExists(scriptFilePaths[i])
			if exists {
				_, err := internal.CopyFile(scriptFilePaths[i], "./scripts/author/"+author+"/"+fileName)
				internal.CheckIfError(err)
			}
		}
	}

	ReverseAllScriptsFileName()
}

func ReverseAllScriptsFileName() {
	//err := internal.CopyDir("./scripts/author/", "./scripts/news/")
	//internal.CheckIfError(err)

	renameFunc := func(str string) string {
		if strings.HasPrefix(str, "z_") {
			return "diy_" + str[len("z_"):]
		} else if strings.HasPrefix(str, "monk_") {
			return "diy_" + str[len("monk_"):]
		} else if strings.HasPrefix(str, "jd_") {
			return "diy_" + str[len("jd_"):]
		} else if strings.HasPrefix(str, "long_") {
			return "diy_" + str[len("long_"):]
		} else if strings.HasPrefix(str, "diy_") {
			return str
		} else {
			return "diy_" + str
		}
	}

	if err := filepath.Walk("./scripts/author", func(path string, info os.FileInfo, err error) error {
		if filepath.Ext(path) == ".js" {
			_ = os.Rename(path, filepath.Dir(path)+"/"+renameFunc(strings.TrimSuffix(filepath.Base(info.Name()), filepath.Ext(info.Name())))+".js")
		}
		return nil
	}); err != nil {
		internal.CheckIfError(err)
	}
}
