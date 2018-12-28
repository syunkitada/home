# websocket

## 基本
* HTTP(厳密にはそれをwebsocketにupgradeしたもの)でクライアントとサーバー間で情報をやり取りしてコネクション確立
* 確立されたコネクション上で、双方向の通信を行う

## コネクションの確立
* クライアントから以下のHTTPリクエストを送る
```
GET /resource HTTP/1.1
Host: example.com
Upgrade: websocket
Connection: upgrade
Sec-WebSocket-Version: 13
Sec-WebSocket-Key: E4WSEcseoWr4csPLS2QJHA==
```

* サーバは以下のレスポンスを返すと、コネクションが確立され、双方向の通信が可能となる
```
HTTP/1.1 101 OK
Upgrade: websocket
Connection: upgrade
Sec-WebSocket-Accept: 7eQChgCtQMnVILefJAO6dK5JwPc=
```
