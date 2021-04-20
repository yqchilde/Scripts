package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/yqchilde/Doraemon/ghttp"

	"jd_scripts/internal"
)

type T struct {
	Files []struct {
		Id           string    `json:"id"`
		Name         string    `json:"name"`
		MimeType     string    `json:"mimeType"`
		ModifiedTime time.Time `json:"modifiedTime"`
		Size         string    `json:"size,omitempty"`
	} `json:"files"`
}

func SpiderOtherScript() {
	Spider("https://share.r2ray.com/dust/")
	FileOperations()
}

func Spider(url string) {
	fmt.Println("开始抓取: ", url)

	headers := map[string]string{
		"accept":                    "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
		"accept-language":           "zh-CN,zh;q=0.9,en;q=0.8",
		"cache-control":             "no-cache",
		"pragma":                    "no-cache",
		"sec-ch-ua":                 `Google Chrome; v = "89", "Chromium"; v = "89", ";Not A Brand"; v = "99"`,
		"sec-ch-ua-mobile":          "?0",
		"sec-fetch-dest":            "document",
		"sec-fetch-mode":            "navigate",
		"sec-fetch-site":            "none",
		"sec-fetch-user":            "?1",
		"upgrade-insecure-requests": "1",
		"user-agent":                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36",
	}

	resp := ghttp.Post(url).AddHeaders(headers).Do()

	files := new(T)
	err := resp.BindJSON(files)
	internal.CheckIfError(err)

	for _, file := range files.Files {
		if file.MimeType == "application/vnd.google-apps.folder" {
			// 判断文件夹是否符合要求
			flag := false
			for _, scriptPath := range []string{"car", "i-chenzhe", "member", "normal"} {
				if file.Name == scriptPath {
					flag = true
					break
				}
			}
			if !flag {
				continue
			}

			// 创建文件夹
			err := os.MkdirAll("./monk-coder/"+file.Name, os.ModePerm)
			if err != nil {
				fmt.Println(err)
				return
			}
			Spider(url + file.Name + "/")
		} else {
			if filepath.Ext(file.Name) != ".js" {
				continue
			}

			fmt.Println("找到文件并下载", url+file.Name)
			// 放在url的文件夹中
			dir := filepath.Base(internal.GetBetweenStr(url, "https://share.r2ray.com/dust/", ""))

			resp := ghttp.Get(url + file.Name).Do()

			f, err := os.OpenFile("./monk-coder/"+dir+"/"+file.Name, os.O_WRONLY|os.O_CREATE, 0644)
			internal.CheckIfError(err)

			_, err = io.Copy(f, strings.NewReader(resp.Text))
			internal.CheckIfError(err)
			_ = f.Close()
		}

		time.Sleep(3 * time.Second)
	}
}

func FileOperations() {
	internal.Info("全部抓取结束")

	err := internal.CopyDir("monk-coder", "i-chenzhe")
	internal.CheckIfError(err)

	for _, author := range []string{"i-chenzhe", "monk-coder"} {
		// 移除旧文件
		internal.Info("移除旧文件")
		err = internal.CopyDir("scripts/author/"+author, "scripts/backup/"+author)
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
}
