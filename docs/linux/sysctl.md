# 

| parameter | default value | description |
| --- | --- | --- |
| net.core.somaxconn | | |
TCPソケットが受け付けた接続要求を格納する、キューの最大長

## TCP SYN cookie protection (default)
## helps protect against SYN flood attacks
## only kicks in when net.ipv4.tcp_max_syn_backlog is reached
net.ipv4.tcp_syncookies = 1

/proc/sys/net/ipv4/tcp_syncookies の値を 1 にすることで SYN flood時に SYN cookies が有効になる
