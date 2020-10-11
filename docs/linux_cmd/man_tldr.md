# man/tldr

## man

```
$ man curl
```

## tldr

```bash
$ tldr curl
curl
Transfers data from or to a server.
Supports most protocols, including HTTP, FTP, and POP3.
More information:
https://curl.haxx.se
.

 - Download the contents of an URL to a file:
    curl {{http://example.com}} -o {{filename}}

 - Download a file, saving the output under the filename indicated by the URL:
    curl -O {{http://example.com/filename}}

 - Download a file, following [L]ocation redirects, and automatically [C]ontinuing (resuming) a previous file transfer:
    curl -O -L -C - {{http://example.com/filename}}
```
