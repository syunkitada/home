# uwsgi


## References
* https://uwsgi-docs.readthedocs.io/en/latest/WSGIquickstart.html


## Hello World
```
$ sudo virtualenv /opt/uwsgi
$ sudo /opt/uwsgi/bin/pip install uwsgi

$ mkdir -p $HOME/python/src/uwsgi-app
$ cd $HOME/python/src/uwsgi-app

$ vim server.py
```

> server.py
```
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World"]
```

``` sh
$ sudo /opt/uwsgi/bin/uwsgi --threads=1 --socket=/var/run/uwsgi.sock --chmod-socket=666 --wsgi-file=server.py
```
