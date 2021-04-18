package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	"github.com/yqchilde/Doraemon/ghttp"

	"jd_scripts/pkg"
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
}

func Spider(url string) {
	fmt.Println("开始抓取: ", url)

	resp := ghttp.Post(url).Do()

	files := new(T)
	err := resp.BindJSON(files)
	pkg.CheckIfError(err)

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
			dir := filepath.Base(pkg.GetBetweenStr(url, "https://share.r2ray.com/dust/", ""))

			resp := ghttp.Get(url + file.Name).Do()

			open, err := os.OpenFile("./monk-coder/"+dir+"/"+file.Name, os.O_WRONLY|os.O_CREATE, 0644)
			pkg.CheckIfError(err)

			_, err = io.Copy(open, resp.Req.Body)
			pkg.CheckIfError(err)

			_ = open.Close()
		}
	}

	_, err = pkg.CopyFile("monk-coder", "i-chenzhe")
	pkg.CheckIfError(err)

	for _, author := range []string{"i-chenzhe", "monk-coder"} {
		// 移除旧文件
		pkg.Info("移除旧文件")
		_, err = pkg.CopyFile("scripts/author/"+author, "scripts/backup/"+author)
		pkg.CheckIfError(err)

		// 开始拷贝文件
		pkg.Info("开始拷贝 %s 脚本", author)

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
							pkg.Warning("%s 的脚本过滤文件规则不一致", k)
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
				pkg.CheckIfError(err)
			}
		}

		// 将文件移到指定项目目录
		pkg.Info("将 %s 脚本移到指定项目目录", author)
		for i := range scriptFilePaths {
			_, fileName := filepath.Split(scriptFilePaths[i])
			exists := pkg.CheckFileExists(scriptFilePaths[i])
			if exists {
				_, err := pkg.CopyFile(scriptFilePaths[i], "./scripts/author/"+author+"/"+fileName)
				pkg.CheckIfError(err)
			}
		}
	}
}
