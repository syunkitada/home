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
	keybindDocs := path.Join(pwd, "docs_env", "keybind")

	// autohotkey
	cmd := "grep '\\[KEYBIND\\]' ~/autohotkey/* -r | sed -e 's/.*\\[KEYBIND\\]//g'"
	appendKeyMapByCmd(modeKeyMap, "n", cmd)

	// vim
	cmd = "grep '\\[KEYBIND\\]' ~/home/xdgconfig/nvim/* -r | sed -e 's/.*\\[KEYBIND\\]//g'"
	appendKeyMapByCmd(modeKeyMap, "vn", cmd)

	// tmux
	cmd = "grep '\\[KEYBIND\\]' ~/home/xdgconfig/tmux/* -r | sed -e 's/.*\\[KEYBIND\\]//g'"
	appendKeyMapByCmd(modeKeyMap, "t", cmd)

	// zsh
	cmd = "grep '\\[COMMAND\\]' ~/home/dotfiles/.zsh/* -r | sed -e 's/.*\\[COMMAND\\]//g'"
	appendKeyMapByCmd(modeKeyMap, "zsh", cmd)

	modeDocMap := map[string]string{}
	for mode, keyMap := range modeKeyMap {
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
		modeDocMap[mode] = strings.Join(docLines, "\n")
	}

	mergeMap := map[string][]string{
		"default": {"n"},
		"vim":     {"vn", "vf", "vt", "vl"},
		"tmux":    {"t"},
		"zsh":     {"zsh"},
	}
	for name, modes := range mergeMap {
		newDocs := []string{}
		for _, mode := range modes {
			doc := modeDocMap[mode]
			newDocs = append(newDocs, "# "+mode+"\n"+doc)
			delete(modeDocMap, mode)
		}
		modeDocMap[name] = strings.Join(newDocs, "\n\n")
	}

	for mode, doc := range modeDocMap {
		modeDoc := path.Join(keybindDocs, mode+".txt")
		if err := ioutil.WriteFile(modeDoc, []byte(doc), 0644); err != nil {
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

		line = strings.Replace(line, "\\\\", "<BACKSLASH>", -1)
		line = strings.Replace(line, "\\;", "<SEMICOLON>", -1)
		splitedLine := strings.Split(line, ";")
		keyBind := KeyBind{Index: i}
		for _, keyValue := range splitedLine {
			keyValues := strings.Split(strings.TrimSpace(keyValue), "=")
			if len(keyValues) != 2 {
				continue
			}
			key := keyValues[0]
			value := keyValues[1]
			value = strings.Replace(value, "<SEMICOLON>", ";", -1)
			value = strings.Replace(value, "<BACKSLASH>", "\\", -1)
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
		case "n", "vn", "vl", "vf", "vt", "t", "zsh", "g", "gf", "gb":
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
