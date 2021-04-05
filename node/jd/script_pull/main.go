package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

var gitAuthorRepoMap = map[string]string{
	"i-chenzhe":  "https://github.com/monk-coder/dust.git",
	"monk-coder": "https://github.com/monk-coder/dust.git",
}

var gitAuthorPathMap = map[string][]string{
	"i-chenzhe":  {"i-chenzhe"},
	"monk-coder": {"car", "member", "normal"},
}

// 这里希望写入 [*(所有文件) | @脚本名字(过滤脚本) | 指定脚本名字] 三种方式
var gitAuthorScripts = map[string][]string{
	"i-chenzhe":  {"@z_getFanslove.js"},
	"monk-coder": {"@monk_inter_shop_sign.js"},
}

const cronRegex = `(((\*|\?|[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}|[0-9]{1,2}\-[0-9]{1,2}\/[0-9]{1,2}|([0-9]{1,2}\,?)*|([0-9]{1,2}\,?)*\-[0-9]{1,2}|([0-9]{1,2}\,?)*\-[0-9]{1,2}\/[0-9]{1,2})+[\s]){5})`

func main() {
	var cronList []string

	// 遍历每个作者项目
	for gitPath, gitRepo := range gitAuthorRepoMap {
		Info("正在处理 %s 的脚本", gitPath)

		hasGitPath, err := CheckPathExists(gitPath)
		CheckIfError(err)

		if !hasGitPath {
			err := CloneScriptRepo(gitRepo, gitPath)
			CheckIfError(err)
		} else {
			err := PullScriptRepo(gitPath)
			if err != nil {
				Warning("%s 的仓库没有更新，即将跳过", gitPath)
				continue
			}
		}

		// 开始拷贝文件
		Info("开始拷贝 %s 脚本", gitPath)
		scriptPaths := gitAuthorPathMap[gitPath]
		scriptFiles := gitAuthorScripts[gitPath]
		var scriptFilePaths []string
		for i := range scriptPaths {

			if len(scriptFiles) == 1 && scriptFiles[0] == "*" {
				allScriptFiles, _ := filepath.Glob(gitPath + "/" + scriptPaths[i] + "/*.js")
				for j := range allScriptFiles {
					scriptFilePaths = append(scriptFilePaths, allScriptFiles[j])
				}
			} else if scriptFiles[0][0] == '@' {
				allScriptFiles, _ := filepath.Glob(gitPath + "/" + scriptPaths[i] + "/*.js")
				for j := range allScriptFiles {
					for k := range scriptFiles {
						if scriptFiles[k][0] != '@' {
							Warning("%s 的脚本过滤文件规则不一致", gitPath)
							cronList = []string{}
							return
						}

						filter := scriptFiles[k][1:]
						if filepath.Base(allScriptFiles[j]) == filter {
							continue
						}
						scriptFilePaths = append(scriptFilePaths, allScriptFiles[j])
					}
				}
			} else {
				for j := range scriptFiles {
					scriptFilePath := gitPath + "/" + scriptPaths[i] + "/" + scriptFiles[j]
					scriptFilePaths = append(scriptFilePaths, scriptFilePath)
				}
			}
		}

		// 将文件移到指定项目目录
		Info("将 %s 脚本移到指定项目目录", gitPath)
		for i := range scriptFilePaths {
			_, fileName := filepath.Split(scriptFilePaths[i])
			exists, _ := CheckPathExists(scriptFilePaths[i])
			if exists {
				_, err := CopyFile(scriptFilePaths[i], "../author/"+gitPath+"/"+fileName)
				CheckIfError(err)
			}
		}

		// 将backup的文件进行过滤
		Info("将 %s backup的脚本进行过滤", gitPath)
		backupFiles, _ := filepath.Glob(gitPath + "/backup/*.js")
		for i := range backupFiles {
			_, fileName := filepath.Split(backupFiles[i])

			exists, _ := CheckPathExists("../author/" + gitPath + "/" + fileName)
			if exists {
				err := os.Rename("../author/"+gitPath+"/"+fileName, "../backup/"+gitPath+"/"+fileName)
				CheckIfError(err)
			}

		}

		// 遍历最新的文件然后生成对应的cron
		Info("遍历当前 %s 的脚本并生成对应的cron", gitPath)
		currentScripts, _ := filepath.Glob("../author/" + gitPath + "/*.js")
		for i := range currentScripts {
			_, fileName := filepath.Split(currentScripts[i])
			fileName = strings.ReplaceAll(fileName, ".js", "")
			cron, active := "", ""
			if file, err := os.Open(currentScripts[i]); err != nil {
				panic(err)
			} else {
				scanner := bufio.NewScanner(file)
				reg := regexp.MustCompile(cronRegex)
				for scanner.Scan() {
					if reg.MatchString(scanner.Text()) {
						cron = strings.Trim(reg.FindString(scanner.Text()), " ")
					}
					if strings.Contains(scanner.Text(), "new Env") {
						active = strings.Trim(GetBetweenStr(scanner.Text(), "new Env('", "')"), " ")
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
		Info("重新写入jd_script.sh")
		type Cron struct {
			CronList []string
		}

		var buf bytes.Buffer
		cron := &Cron{CronList: cronList}
		t := template.Must(template.New("jd_script").Parse(GetScriptTemplate()))
		err := t.Execute(&buf, cron)
		if err != nil {
			Warning("Executing template:", err)
		}

		f, err := os.OpenFile("../jd_script.sh", os.O_WRONLY|os.O_TRUNC|os.O_CREATE, 0644)
		if err != nil {
			CheckIfError(err)
		}
		n, _ := f.Seek(0, io.SeekEnd)
		_, _ = f.WriteAt(buf.Bytes(), n)
		defer f.Close()
	}

	Info("项目结束")
}

func CloneScriptRepo(repo, path string) error {
	_, err := RunGitCommand("./", "git", "clone", repo, path)

	return err
}

func PullScriptRepo(gitPath string) error {
	_, err := RunGitCommand(gitPath, "git", "pull", "origin")

	return err
}

func RunGitCommand(gitPath, name string, arg ...string) (string, error) {
	cmd := exec.Command(name, arg...)
	cmd.Dir = gitPath
	msg, _ := cmd.CombinedOutput()
	err := cmd.Run()
	return string(msg), err
}

func CheckPathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

func CopyFile(srcName, dstName string) (written int64, err error) {
	src, err := os.Open(srcName)
	if err != nil {
		return
	}
	defer src.Close()

	dst, err := os.OpenFile(dstName, os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		return
	}
	defer dst.Close()

	return io.Copy(dst, src)
}

func GetScriptTemplate() string {
	return `#!/bin/bash

function initGitRepo() {
   git clone https://gitee.com/yqchilde/Scripts.git /ybRepo
}

if [ ! -d "/ybRepo/" ]; then
   echo "未检查到ybRepo仓库脚本，初始化下载相关脚本"
   initGitRepo
else
   echo "更新ybRepo脚本相关文件"
   git -C /ybRepo reset --hard
   git -C /ybRepo pull --rebase
fi

cp $(find /ybRepo/node/jd/author -type f -name "*.js") /scripts/

{
  {{- range $_, $cron := .CronList}}
  {{ $cron -}}
  {{- end }}
} >> /scripts/docker/merged_list_file.sh
`
}

func GetBetweenStr(str, start, end string) string {
	n := strings.Index(str, start)
	if n == -1 {
		n = 0
	} else {
		n = n + len(start)
	}
	str = string([]byte(str)[n:])
	m := strings.Index(str, end)
	if m == -1 {
		m = len(str)
	}
	str = string([]byte(str)[:m])
	return str
}

func CheckIfError(err error) {
	if err == nil {
		return
	}

	fmt.Printf("\x1b[31;1m%s\x1b[0m\n", fmt.Sprintf("error: %s", err))
	os.Exit(1)
}

func Info(format string, args ...interface{}) {
	fmt.Printf("\x1b[34;1m%s\x1b[0m\n", fmt.Sprintf(format, args...))
}

func Warning(format string, args ...interface{}) {
	fmt.Printf("\x1b[36;1m%s\x1b[0m\n", fmt.Sprintf(format, args...))
}
