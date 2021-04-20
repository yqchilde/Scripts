package main

import (
	"fmt"

	"github.com/AlecAivazis/survey/v2"

	"jd_scripts/internal"
)

func main() {
	answers := []string{
		"1. 抓取git仓库作者脚本",
		"2. 抓取其他地址脚本",
		"3. 根据脚本生成jd_script.sh",
	}

	Prompt := &internal.Select{
		Message: "请选择对应的项目:",
		Options: answers,
	}

	var choice int
	err := survey.AskOne(Prompt, &choice, survey.WithValidator(survey.Required))
	if err != nil {
		fmt.Println(err.Error())
		return
	}

	switch choice {
	case SelectTypePullGitRepo:
		GitCloneRepo()
	case SelectTypeSpiderOtherScript:
		SpiderOtherScript()
	case SelectTypeGenerateJdScriptShell:
		GenerateJDScriptShell()
	}
}
