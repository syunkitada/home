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

keybind_doc:
	go run setup/scripts/gen_keybind_doc.go


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
tester-bash-ubuntu20:
	sudo docker exec -it tester_ubuntu20_1 bash
# ----------------------------------------------------------------------------------------------------
