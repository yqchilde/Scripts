package main

import (
	"bytes"
	"os"
	"os/exec"

	"jd_scripts/pkg"
)

func CloneScriptRepo(repo, path, branch string) (string, error) {
	if branch == "" {
		return RunGitCommand("./", "git", "clone", repo, path)
	}
	return RunGitCommand("./", "git", "clone", "-b", branch, repo, path)
}

func PullScriptRepo(gitPath string) (string, error) {
	return RunGitCommand(gitPath, "git", "pull", "origin")
}

func RunGitCommand(gitPath, name string, arg ...string) (string, error) {
	var out bytes.Buffer

	cmd := exec.Command(name, arg...)
	cmd.Stdout = &out
	cmd.Stderr = os.Stderr
	cmd.Dir = gitPath
	err := cmd.Start()
	if err != nil {
		pkg.Warning("exec.Command failed, err: ", err.Error())
		os.Exit(1)
	}
	err = cmd.Wait()

	return out.String(), err
}
