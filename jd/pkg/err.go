package pkg

import (
	"fmt"
	"os"
)

// CheckIfError should be used to naively panics if an error is not nil.
func CheckIfError(err error) {
	if err == nil {
		return
	}

	fmt.Printf("\x1b[31;1m%s\x1b[0m\n", fmt.Sprintf("error: %s", err))
	os.Exit(1)
}

// Info should be used to describe the example commands that are about to run.
func Info(format string, args ...interface{}) {
	fmt.Printf("\033[1;36m%s\033[0m\n", fmt.Sprintf(format, args...))
}

// Warning should be used to display a warning
func Warning(format string, args ...interface{}) {
	fmt.Printf("\033[31m%s\033[0m\n", fmt.Sprintf(format, args...))
}
