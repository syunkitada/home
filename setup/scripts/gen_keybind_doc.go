package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"sort"
	"strconv"
	"strings"
)

type KeyBind struct {
	Index  int
	Mode   string
	Key    string
	Tags   string
	Action string
}

func main() {
	modeKeyMap := map[string]map[string]KeyBind{}

	pwd := os.Getenv("PWD")
	keybindDocs := path.Join(pwd, "env_docs", "keybind")

	// autohotkey
	cmd := "grep '; \\[KEYBIND\\]' ~/autohotkey/* -r | awk -F '\\[KEYBIND\\]' '{print $2}'"
	appendKeyMapByCmd(modeKeyMap, "n", cmd)

	// vim
	cmd = "grep '\" \\[KEYBIND\\]' ~/home/dotconfig/nvim/* -r | awk -F '\\[KEYBIND\\]' '{print $2}'"
	appendKeyMapByCmd(modeKeyMap, "vn", cmd)

	// tmux
	cmd = "grep '# \\[KEYBIND\\]' ~/home/dotfiles/.tmux.conf -r | awk -F '\\[KEYBIND\\]' '{print $2}'"
	appendKeyMapByCmd(modeKeyMap, "t", cmd)

	// zsh
	cmd = "grep '# \\[COMMAND\\]' ~/home/dotfiles/.zsh/* -r | awk -F '\\[COMMAND\\]' '{print $2}'"
	appendKeyMapByCmd(modeKeyMap, "z", cmd)

	for mode, keyMap := range modeKeyMap {
		modeDoc := path.Join(keybindDocs, mode+".txt")
		maxKeyLength := 0
		maxTagsLength := 0
		keyBinds := []KeyBind{}
		for key, keyBind := range keyMap {
			if len(key) > maxKeyLength {
				maxKeyLength = len(key)
			}
			if len(keyBind.Tags) > maxTagsLength {
				maxTagsLength = len(keyBind.Tags)
			}
			keyBinds = append(keyBinds, keyBind)
		}

		sort.Slice(keyBinds, func(i, j int) bool {
			return keyBinds[i].Index < keyBinds[j].Index
		})

		docLines := []string{}
		formatLine := "%-" + strconv.Itoa(maxKeyLength) + "s  %-" + strconv.Itoa(maxTagsLength) + "s  %s"
		for _, keyBind := range keyBinds {
			docLines = append(docLines, fmt.Sprintf(formatLine, keyBind.Key, keyBind.Tags, keyBind.Action))
		}

		if err := ioutil.WriteFile(modeDoc, []byte(strings.Join(docLines, "\n")), 0644); err != nil {
			log.Fatalf("Failed WriteFile: err=%s", err.Error())
		}
		fmt.Printf("Generated: file=%s\n", modeDoc)
	}
}

func appendKeyMapByCmd(modeKeyMap map[string]map[string]KeyBind, defaultMode string, cmd string) {
	output, err := exec.Command("sh", "-c", cmd).CombinedOutput()
	if err != nil {
		log.Fatalf("Failed grep: err=%s", err.Error())
	}
	keyBindLines := strings.Split(string(output), "\n")
	appendKeyMap(modeKeyMap, defaultMode, keyBindLines)
}

func appendKeyMap(modeKeyMap map[string]map[string]KeyBind, defaultMode string, lines []string) {
	for i, line := range lines {
		line = strings.TrimSpace(line)
		if len(line) == 0 {
			continue
		}
		splitedLine := strings.Split(line, ";")
		keyBind := KeyBind{Index: i}
		for _, keyValue := range splitedLine {
			keyValues := strings.Split(strings.TrimSpace(keyValue), "=")
			if len(keyValues) != 2 {
				continue
			}
			key := keyValues[0]
			value := keyValues[1]
			switch key {
			case "mode":
				keyBind.Mode = value
			case "key":
				keyBind.Key = value
			case "tags":
				keyBind.Tags = "[" + strings.Join(strings.Split(value, ","), "][") + "]"
			case "action":
				keyBind.Action = value
			}
		}
		if keyBind.Mode == "" {
			keyBind.Mode = defaultMode
		}
		switch keyBind.Mode {
		case "n", "vn", "vf", "vt", "t", "z":
		default:
			log.Fatalf("Unexpected Mode: mode=%s, line=%s", keyBind.Mode, line)
		}

		keyMap, ok := modeKeyMap[keyBind.Mode]
		if !ok {
			keyMap = map[string]KeyBind{}
		}
		if tmpKeyBind, ok := keyMap[keyBind.Key]; ok {
			log.Fatalf("DuplicatedKeyFound: mode=%s, key=%s, action1=%s, action2=%s", keyBind.Mode, keyBind.Key, tmpKeyBind.Action, keyBind.Action)
		}
		keyMap[keyBind.Key] = keyBind
		modeKeyMap[keyBind.Mode] = keyMap
	}
}
