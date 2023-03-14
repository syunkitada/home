index:
	cd docs; go run makeindex.go;
	cp /tmp/index.json ../home-index/

deploy:
	cd ../home-index/; git commit -am 'update'; git push

centos7:
	./setup/scripts/link_dotfiles.sh
	./setup/scripts/setup_centos7.sh

ubuntu20:
	./setup/scripts/link_dotfiles.sh
	./setup/scripts/setup_ubuntu20.sh

gen_keybind_doc:
	go run setup/scripts/gen_keybind_doc.go

clone_programming_repos:
	test -e ~/programming_go || git clone git@github.com:syunkitada/programming_go.git ~/programming_go
	test -e ~/programming_c || git clone git@github.com:syunkitada/programming_c.git ~/programming_c
	test -e ~/programming_rust || git clone git@github.com:syunkitada/programming_rust.git ~/programming_rust
	test -e ~/programming_python || git clone git@github.com:syunkitada/programming_python.git ~/programming_python
	test -e ~/programming_web || git clone git@github.com:syunkitada/programming_web.git ~/programming_web


# ----------------------------------------------------------------------------------------------------
# tester
# ----------------------------------------------------------------------------------------------------
UID := $(shell id -u)
GID := $(shell id -g)

tester:
	cd setup/tester; UID=${UID} GID=${GID} sudo -E docker-compose up -d

tester-build:
	cd setup/tester; UID=${UID} GID=${GID} sudo -E docker-compose build

tester-clean:
	cd setup/tester; UID=${UID} GID=${GID} sudo -E docker-compose down

tester-bash-centos7:
	sudo docker exec -it tester_centos7_1 bash
tester-ssh-centos7:
	ssh 10.100.11.2
tester-bash-rocky8:
	sudo docker exec -it tester_rocky8_1 bash
tester-bash-ubuntu20:
	sudo docker exec -it tester_ubuntu20_1 bash
# ----------------------------------------------------------------------------------------------------
