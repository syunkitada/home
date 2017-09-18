# nginx

## uwsgi
```
uwsgi --socket 127.0.0.1:8080 --process 4 --wsgi-file wsgi.py &>/dev/null &
```

wsig.py
``
def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return ["Hello World"]
```


## PHP-FPM

sudo yum install php-fpm

/etc/php-fpm.d/www.conf
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nobody
listen.group = nobody

php-fpm
```
server {
    listen       6080;

    root   /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}

```


sudo vim /usr/share/nginx/html/info.php
<?php echo "hello"; ?>


curl localhost:6080/info.php


## チューニング
http://qiita.com/sion_cojp/items/c02b5b5586b48eaaa469
