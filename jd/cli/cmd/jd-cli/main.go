package main

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"time"

	"github.com/AlecAivazis/survey/v2"
	"github.com/cheggaaa/pb/v3"
	"github.com/google/go-github/v35/github"

	"jd_scripts/internal"
)

var (
	Version = ""
	Project = "jd-cli"
)

func main() {
	v := flag.Bool("v", false, "version")
	flag.Parse()

	if *v {
		fmt.Println("当前版本: " + Version)
		return
	}

	// 检查是否有更新
	ctx := context.Background()
	client := github.NewClient(nil)
	release, _, _ := client.Repositories.GetLatestRelease(ctx, "yqchilde", "scripts")

	if Version != release.GetTagName() {
		fmt.Println(release.GetBody())
		fmt.Print("发现新版本，是否要更新到", release.GetTagName(), " (y/n): ")
		input, err := bufio.NewReader(os.Stdin).ReadString('\n')
		if err != nil || (input != "y\n" && input != "n\n") || input == "n\n" {
			internal.ClearTerminal(runtime.GOOS)
		}

		if input == "y\n" {
			for _, asset := range release.Assets {
				sourceName := fmt.Sprintf("jd-cli-%s-%s.tar.gz", runtime.GOOS, runtime.GOARCH)
				if asset.GetName() == sourceName {
					ToUpdateProgram(asset.GetBrowserDownloadURL())
					return
				}
			}
		}
	}

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

func ToUpdateProgram(url string) {
	// 拿到压缩包文件名
	tarGzFileName := filepath.Base(url)

	client := http.DefaultClient
	client.Timeout = time.Second * 60 * 10
	resp, err := client.Get(url)
	if err != nil {
		log.Fatal(err)
	}

	if resp.StatusCode == http.StatusOK {
		log.Printf("[INFO] 正在更新: [%s]", Project)
		downFile, err := os.Create(tarGzFileName)
		internal.CheckIfError(err)
		defer downFile.Close()

		// 获取下载文件的大小
		contentLength, _ := strconv.Atoi(resp.Header.Get("Content-Length"))
		sourceSiz := int64(contentLength)
		source := resp.Body

		// 创建一个进度条
		bar := pb.Full.Start64(sourceSiz)
		bar.SetMaxWidth(100)
		barReader := bar.NewProxyReader(source)
		writer := io.MultiWriter(downFile)
		_, err = io.Copy(writer, barReader)
		bar.Finish()

		// 检查文件大小
		stat, _ := os.Stat(tarGzFileName)
		if stat.Size() != int64(contentLength) {
			log.Printf("[ERROR] [%s]更新失败", Project)
			err := os.Remove(tarGzFileName)
			internal.CheckIfError(err)
			return
		}

		log.Printf("[INFO] [%s]更新成功", Project)
		err = internal.TarGzDeCompress(tarGzFileName, "./")
		internal.CheckIfError(err)

		_ = os.Remove(tarGzFileName)
		_ = os.Chmod(Project, os.ModePerm)

		internal.ClearTerminal(runtime.GOOS)
		_ = internal.RestartProcess("./" + Project)
	} else {
		log.Printf("[ERROR] [%s]更新失败", Project)
		_ = os.Remove(tarGzFileName)
	}
}
