package internal

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
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
