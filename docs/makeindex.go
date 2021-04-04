package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"path/filepath"
)

type FileInfo struct {
	Path string
	Text string
}

func dirwalk(dir string) (fileInfos []FileInfo) {
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		panic(err)
	}

	for _, file := range files {
		if file.IsDir() {
			fileInfos = append(fileInfos, dirwalk(filepath.Join(dir, file.Name()))...)
			continue
		} else {
			var path string
			if dir != "." {
				path = filepath.Join(dir, file.Name())
			} else {
				path = file.Name()
			}
			content, err := ioutil.ReadFile(path)
			if err != nil {
				log.Fatalf("Failed ioutil.ReadFile: err=%s", err.Error())
			}
			contentType := http.DetectContentType(content)
			if contentType == "text/plain; charset=utf-8" {
				fileInfo := FileInfo{
					Path: path,
					Text: string(content),
				}
				fileInfos = append(fileInfos, fileInfo)
			}
		}
	}
	return
}

type IndexData struct {
	Entry                 int
	TokenDocumentIndexMap map[string]map[int][]int // [token]: [documentId][tokenIndex]
	IdTextMap             []string
	IdPathMap             []string
	PathMap               map[string]int
}

func main() {
	fileInfos := dirwalk(".")
	idTextMap := []string{}
	idPathMap := []string{}
	pathMap := map[string]int{}
	var entry int
	for i, file := range fileInfos {
		idTextMap = append(idTextMap, file.Text)
		idPathMap = append(idPathMap, file.Path)
		pathMap[file.Path] = i
		if file.Path == "INDEX.md" {
			entry = i
		}
	}

	indexData := IndexData{
		Entry:     entry,
		IdTextMap: idTextMap,
		IdPathMap: idPathMap,
		PathMap:   pathMap,
	}

	bytes, err := json.Marshal(indexData)
	if err != nil {
		log.Fatalf("Failed json.Marshal: err=%s", err.Error())
	}

	if err := ioutil.WriteFile("/tmp/index.json", bytes, 0644); err != nil {
		log.Fatalf("Failed WriteFile index.json: err=%s", err.Error())
	}
}
