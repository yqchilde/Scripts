package main

import (
	"fmt"

	"github.com/AlecAivazis/survey/v2"

	"jd_scripts/internal"
)

func main() {
	answers := []string{
		"1. 生成docker-compose.yml模板",
		"2. 生成.env配置文件模板",
		"3. 扫码登录JD并获取Cookie",
		"4. 查询并生成自己所有助力码",
		"5. 整理写入好友所有助力码",
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
	case SelectTypeGenerateDockerCompose:
		var num int
		err := survey.AskOne(&survey.Input{
			Message: "请输入要生成的容器数量",
		}, &num)
		internal.CheckIfError(err)
		GenerateDockerComposeTemplate(num)
	case SelectTypeGenerateDotEnvFile:
		GenerateDotEnvFile()
	case SelectTypeQrScanLogin:
		JDLoginByQrScan()
	case SelectTypeQuerySelfShareCode:
		QuerySelfShareCode(SearchShareCodeCollectionFilePaths())
	case SelectTypeFormatFriendShareCode:
		FormatFriendShareCode()
	}
}
