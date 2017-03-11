# apache bench(ab)

abは、Apache Benchの略で、Apacheに標準でついてくるベンチマークツールです。

## Install
``` bash
# Install
$ yum install httpd
```

## Run ab
```
$ ab -n 1000 -c 100 http://192.168.122.101/

# Options
$ ab -h
Usage: ab [options] [http[s]://]hostname[:port]/path
Options are:
    -n requests     Number of requests to perform
    -c concurrency  Number of multiple requests to make at a time
    -t timelimit    Seconds to max. to spend on benchmarking
                    This implies -n 50000
    -s timeout      Seconds to max. wait for each response
                    Default is 30 seconds
    -b windowsize   Size of TCP send/receive buffer, in bytes
    -B address      Address to bind to when making outgoing connections
    -p postfile     File containing data to POST. Remember also to set -T
    -u putfile      File containing data to PUT. Remember also to set -T
    -T content-type Content-type header to use for POST/PUT data, eg.
                    'application/x-www-form-urlencoded'
                    Default is 'text/plain'
    -v verbosity    How much troubleshooting info to print
    -w              Print out results in HTML tables
    -i              Use HEAD instead of GET
    -x attributes   String to insert as table attributes
    -y attributes   String to insert as tr attributes
    -z attributes   String to insert as td or th attributes
    -C attribute    Add cookie, eg. 'Apache=1234'. (repeatable)
    -H attribute    Add Arbitrary header line, eg. 'Accept-Encoding: gzip'
                    Inserted after all normal header lines. (repeatable)
    -A attribute    Add Basic WWW Authentication, the attributes
                    are a colon separated username and password.
    -P attribute    Add Basic Proxy Authentication, the attributes
                    are a colon separated username and password.
    -X proxy:port   Proxyserver and port number to use
    -V              Print version number and exit
    -k              Use HTTP KeepAlive feature
    -d              Do not show percentiles served table.
    -S              Do not show confidence estimators and warnings.
    -q              Do not show progress when doing more than 150 requests
    -g filename     Output collected data to gnuplot format file.
    -e filename     Output CSV file with percentages served
    -r              Don't exit on socket receive errors.
    -h              Display usage information (this message)
    -Z ciphersuite  Specify SSL/TLS cipher suite (See openssl ciphers)
    -f protocol     Specify SSL/TLS protocol
                    (SSL2, SSL3, TLS1, TLS1.1, TLS1.2 or ALL)
```

## Run and output
``` bash
$ ab -n 1000 -c 100 http://192.168.122.101/
This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 192.168.122.101 (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        Apache/2.4.6
Server Hostname:        192.168.122.101
Server Port:            80

Document Path:          /
Document Length:        4897 bytes

Concurrency Level:      100
Time taken for tests:   0.273 seconds
Complete requests:      1000
Failed requests:        0
Write errors:           0
Non-2xx responses:      1000
Total transferred:      5168000 bytes
HTML transferred:       4897000 bytes
Requests per second:    3667.19 [#/sec] (mean)
Time per request:       27.269 [ms] (mean)
Time per request:       0.273 [ms] (mean, across all concurrent requests)
Transfer rate:          18507.87 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    1   1.8      0       7
Processing:     1   25   5.1     25      34
Waiting:        1   25   5.1     25      34
Total:          6   26   4.4     26      35

Percentage of the requests served within a certain time (ms)
  50%     26
  66%     28
  75%     29
  80%     30
  90%     32
  95%     33
  98%     34
  99%     34
 100%     35 (longest request)
```

## Output
* Server Software
    The value, if any, returned in the server HTTP header of the first successful response. This includes
    all  characters  in the header from beginning to the point a character with decimal value of 32 (most
    notably: a space or CR/LF) is detected.
* Server Hostname
    The DNS or IP address given on the command line
* Server Port
    The port to which ab is connecting. If no port is given on the command line, this will default to  80
    for http and 443 for https.
* SSL/TLS Protocol
    The protocol parameters negotiated between the client and server. This will only be printed if SSL is
    used.
* Document Path
    The request URI parsed from the command line string.
* Document Length
    This is the size in bytes of the first successfully returned document. If the document length changes
    during testing, the response is considered an error.
* Concurrency Level
    The number of concurrent clients used during the test
* Time taken for tests
    This  is the time taken from the moment the first socket connection is created to the moment the last
    response is received
* Complete requests
    The number of successful responses received
* Failed requests
    The number of requests that were considered a failure. If the number is greater  than  zero,  another
    line will be printed showing the number of requests that failed due to connecting, reading, incorrect
    content length, or exceptions.
* Write errors
    The number of errors that failed during write (broken pipe).
* Non-2xx responses
    The number of responses that were not in the 200 series of response codes. If all responses were 200,
    this field is not printed.
* Keep-Alive requests
    The number of connections that resulted in Keep-Alive requests
* Total body sent
    If  configured  to  send  data as part of the test, this is the total number of bytes sent during the
    tests. This field is omitted if the test did not include a body to send.
* Total transferred
    The total number of bytes received from the server. This number is essentially the  number  of  bytes
    sent over the wire.
* HTML transferred
    The  total  number of document bytes received from the server. This number excludes bytes received in
    HTTP headers
