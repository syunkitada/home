## Webserver


## Apache: モジュールとCGI
* モジュール
  * Webサーバのプロセスの中でPHPを実行する
* CGI
  * リクエストのたびにPHPをロードしして実行する


## Nginx: PHP-FPM
* PHP-FPM: FastCGI Process Manager
* NginxとPHP-FPMがTCPソケット or UNIXドメインソケットで通信する
* client -> Nginx -> PHP-FPM


## Nginx: uWSGI
* NginxとuWSGIがTCPソケット or UNIXドメインソケットで通信する
* client -> Nginx -> uWSGI
