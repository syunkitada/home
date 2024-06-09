index:
	cd docs; go run makeindex.go;
	cp /tmp/index.json ../home-index/

deploy:
	cd ../home-index/; git commit -am 'update'; git push

gen_keybind_doc:
	go run scripts/gen_keybind_doc.go

clone_programming_repos:
	test -e ~/programming_go || git clone git@github.com:syunkitada/programming_go.git ~/programming_go
	test -e ~/programming_c || git clone git@github.com:syunkitada/programming_c.git ~/programming_c
	test -e ~/programming_rust || git clone git@github.com:syunkitada/programming_rust.git ~/programming_rust
	test -e ~/programming_python || git clone git@github.com:syunkitada/programming_python.git ~/programming_python
	test -e ~/programming_web || git clone git@github.com:syunkitada/programming_web.git ~/programming_web

.PHONY: setup
setup:
	./scripts/setup.sh

.PHONY: check
check:
	./scripts/check.sh
