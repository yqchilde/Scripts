package internal

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"unicode"
)

func GetBetweenStr(str, startIdx, endIdx string) string {
	start := strings.Index(str, startIdx)
	end := strings.Index(str, endIdx)

	if start != -1 && endIdx == "" {
		return str[start+len(startIdx):]
	} else if start != -1 && end != -1 {
		return str[start+len(startIdx) : end]
	} else {
		return ""
	}
}

func GetKeys(m map[string]string) []string {
	keys := make([]string, 0, len(m))
	for key := range m {
		keys = append(keys, key)
	}
	return keys
}

func CheckFileExists(filePath string) bool {
	fileInfo, err := os.Stat(filePath)
	if fileInfo != nil && err == nil {
		return true
	} else if os.IsNotExist(err) {
		return false
	}
	return false
}

func IsHan(str string) bool {
	for _, s := range str {
		if unicode.Is(unicode.Han, s) {
			return true
		}
	}

	return false
}

func CopyFile(src, dst string) (written int64, err error) {
	in, err := os.Open(src)
	if err != nil {
		return
	}
	defer in.Close()

	out, err := os.OpenFile(dst, os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		return
	}
	defer out.Close()

	return io.Copy(out, in)
}

func CopyDir(src string, dst string) (err error) {
	src = filepath.Clean(src)
	dst = filepath.Clean(dst)

	si, err := os.Stat(src)
	if err != nil {
		return
	}
	if !si.IsDir() {
		return fmt.Errorf("source is not a directory")
	}

	_, err = os.Stat(dst)
	if err != nil && !os.IsNotExist(err) {
		return
	}

	err = os.MkdirAll(dst, si.Mode())
	if err != nil {
		return
	}

	entries, err := ioutil.ReadDir(src)
	if err != nil {
		return
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		if entry.IsDir() {
			err = CopyDir(srcPath, dstPath)
			if err != nil {
				return
			}
		} else {
			if entry.Mode()&os.ModeSymlink != 0 {
				continue
			}

			_, err = CopyFile(srcPath, dstPath)
			if err != nil {
				return
			}
		}
	}

	return
}

// RestartProcess 重启进程
func RestartProcess(proName string) error {
	argv0, err := exec.LookPath(proName)
	if err != nil {
		return err
	}

	return syscall.Exec(argv0, os.Args, os.Environ())
}

// ClearTerminal 清空终端控制台
func ClearTerminal(goos string) {
	switch goos {
	case "darwin":
		cmd := exec.Command("clear")
		cmd.Stdout = os.Stdout
		_ = cmd.Run()
	case "linux":
		cmd := exec.Command("clear")
		cmd.Stdout = os.Stdout
		_ = cmd.Run()
	}
}

// TarGzDeCompress tar.gz解压函数
func TarGzDeCompress(tarFile, dest string) error {
	srcFile, err := os.Open(tarFile)
	if err != nil {
		return err
	}
	defer srcFile.Close()
	gr, err := gzip.NewReader(srcFile)
	if err != nil {
		return err
	}
	defer gr.Close()
	tr := tar.NewReader(gr)
	for {
		hdr, err := tr.Next()
		if err != nil {
			if err == io.EOF {
				break
			} else {
				return err
			}
		}
		filename := dest + hdr.Name

		err = os.MkdirAll(string([]rune(filename)[0:strings.LastIndex(filename, "/")]), 0755)
		if err != nil {
			return err
		}

		file, err := os.Create(filename)
		if err != nil {
			return err
		}
		io.Copy(file, tr)
	}
	return nil
}
