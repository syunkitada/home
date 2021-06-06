index:
	cd docs; go run makeindex.go;
	cp /tmp/index.json ../home-index/

deploy:
	cd ../home-index/; git commit -am 'update'; git push
