# siege

## Install
``` bash
$ sudo yum install -y epel-release
$ sudo yum install -y siege
```

## Run siege
``` bash
# Access url, by 1 user, in 10 secconds
$ siege -v -c 1 -t 2S http://192.168.122.101/

# Benchmark random urls from file, by 300 user, in 10 secconds
$ siege -c 300 -t 10S -b -i --log=/tmp/siege.log -f urls.txt

$ cat urls.txt
https://sample.jp
https://sample.jp/search/tag
https://sample.jp/id/test


# Options
Usage: siege [options]
       siege [options] URL
       siege -g URL
Options:
  -V, --version             VERSION, prints the version number.
  -h, --help                HELP, prints this section.
  -C, --config              CONFIGURATION, show the current config.
  -v, --verbose             VERBOSE, prints notification to screen.
  -q, --quiet               QUIET turns verbose off and suppresses output.
  -g, --get                 GET, pull down HTTP headers and display the
                            transaction. Great for application debugging.
  -c, --concurrent=NUM      CONCURRENT users, default is 10
  -r, --reps=NUM            REPS, number of times to run the test.
  -t, --time=NUMm           TIMED testing where "m" is modifier S, M, or H
                            ex: --time=1H, one hour test.
  -d, --delay=NUM           Time DELAY, random delay before each requst
  -b, --benchmark           BENCHMARK: no delays between requests.
  -i, --internet            INTERNET user simulation, hits URLs randomly.
  -f, --file=FILE           FILE, select a specific URLS FILE.
  -R, --rc=FILE             RC, specify an siegerc file
  -l, --log[=FILE]          LOG to FILE. If FILE is not specified, the
                            default is used: PREFIX/var/siege.log
  -m, --mark="text"         MARK, mark the log file with a string.
                            between .001 and NUM. (NOT COUNTED IN STATS)
  -H, --header="text"       Add a header to request (can be many)
  -A, --user-agent="text"   Sets User-Agent in request
  -T, --content-type="text" Sets Content-Type in request
```


## Run and output
``` bash
$ siege -v -c 1 -t 2S http://192.168.122.101/
** SIEGE 4.0.2
** Preparing 1 concurrent users for battle.
The server is now under siege...
HTTP/1.1 200     0.01 secs:       6 bytes ==> GET  /
HTTP/1.1 200     0.00 secs:       6 bytes ==> GET  /
HTTP/1.1 200     0.01 secs:       6 bytes ==> GET  /
HTTP/1.1 200     0.00 secs:       6 bytes ==> GET  /
HTTP/1.1 200     0.00 secs:       6 bytes ==> GET  /

Lifting the server siege...
Transactions:                      5 hits
Availability:                 100.00 %
Elapsed time:                   1.30 secs
Data transferred:               0.00 MB
Response time:                  0.00 secs
Transaction rate:               3.85 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                    0.02
Successful transactions:           5
Failed transactions:               0
Longest transaction:            0.01
Shortest transaction:           0.00
```

## Output
* Transactions  
    This number represents the total number of HTTP requests. In this
    example, we ran 25 simulated users [-c25] and each ran ten times
    [-r10]. Twenty-five times ten equals 250 so why is the transaction
    total 2000? That's because siege counts every request. This run
    included a META redirect, a 301 redirect and the page it requested
    contained several elements that were also downloaded.
* Availability  
    This is the percentage of socket connections successfully handled
    by the server. It is the result of socket failures (including
    timeouts) divided by the sum of all connection attempts. This
    number does not include 400 and 500 level server errors which are
    recorded in "Failed transactions" described below.
* Elapsed time  
    The duration of the entire siege test. This is measured from the
    time the user invokes siege until the last simulated user
    completes its transactions. Shown above, the test took 14.67
    seconds to complete.
* Data transferred  
    The sum of data transferred to every siege simulated user. It
    includes the header information as well as content. Because it
    includes header information, the number reported by siege will
    be larger then the number reported by the server. In internet
    mode, which hits random URLs in a configuration file, this
    number is expected to vary from run to run.
* Response time  
    The average time it took to respond to each simulated user's requests.
* Transaction rate  
    The average number of transactions the server was able to handle
    per second, in a nutshell: it is the count of all transactions
    divided by elapsed time.
* Throughput
    The average number of bytes transferred every second from the
    server to all the simulated users.
* Concurrency  
    This is the average number of simultaneous connections. The metric
    is calculated like this: the sum of all transaction times divided
    by elapsed time (how long siege ran)
* Successful transactions  
    The number of times the server responded with a return code < 400.
* Failed transactions  
    The number of times the socket transactions failed which includes
    socket timeouts.
* Longest transaction  
    The greatest amount of time that any single transaction took, out
    of all transactions.
* Shortest transaction  
    The smallest amount of time that any single transaction took, out
    of all transactions.
