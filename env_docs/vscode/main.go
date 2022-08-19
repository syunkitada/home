package main

import (
	"fmt"

	do "gopkg.in/godo.v2"
)

func tasks(p *do.Project) {
	p.Task("hoge", nil, func(c *do.Context) {
		c.Run(fmt.Sprintf("rsync -t -r --delete --exclude .git/* --exclude vendor* --exclude *node_modules* %s %s",
			"hoge/",
			"192.168.10.2:go/src/github.com/syunkitada/hoge/"))
	}).Src("hoge/**/*.{go,tsx}")
}

func main() {
	do.Godo(tasks)
}
