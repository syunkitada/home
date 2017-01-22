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
