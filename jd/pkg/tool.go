package pkg

import (
	"io"
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

func RemovePathFiles(path string) error {
	files, err := filepath.Glob(filepath.Join(path, "*"))
	if err != nil {
		return err
	}

	for _, file := range files {
		err = os.RemoveAll(file)
		if err != nil {
			return err
		}
	}

	return nil
}
