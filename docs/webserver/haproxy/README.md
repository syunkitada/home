# HAProxy

## References
| リンク | 説明 |
| --- | --- |
| [HAProxy vs nginx](https://thehftguy.com/2016/10/03/haproxy-vs-nginx-why-you-should-never-use-nginx-for-load-balancing/) |  |
| [Datadog-HAProxy Integration](http://docs.datadoghq.com/integrations/haproxy/) | |
| [haproxy-quickstart](http://chase-seibert.github.io/blog/2011/02/26/haproxy-quickstart-w-full-example-config-file.html) | |
| [True Zero Downtime HAProxy Reloads](https://engineeringblog.yelp.com/2015/04/true-zero-downtime-haproxy-reloads.html) | |


## Reload
新しいプロセスが生成されて、新規コネクションは新しいプロセスで受け付ける
古いプロセスはそれまでのコネクションがすべて切断されたタイミングで終了する

haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)



## tuning
http://www.slideshare.net/haproxytech/haproxy-best-practice

https://www.haproxy.com/doc/hapee/1.5/system/tunning.html 
networkのirqをcoreにpinningできる

## irqbalance
http://nopipi.hatenablog.com/entry/2012/08/15/163742

# mode natでudpいける？
director dns 192.168.0.100:53
 balance roundrobin
 mode nat
 check timeout 2 interval 5
 option tcpcheck
 server server1 192.168.1.10:53 weight 10 check
 server server2 192.168.1.11:53 weight 10 check


## stats
```
watch 'echo "show stat" | nc -U /var/lib/haproxy/stats | cut -d "," -f 1,2,5-11,18,24,27,30,36,50,37,56,57,62 | column -s, -t'
```
