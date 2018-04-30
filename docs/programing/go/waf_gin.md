# gin


## References
* https://github.com/gin-gonic/gin


## Hello World
``` sh
$ echo $GOPATH
/home/owner/go

# Install
$ go get -u github.com/gin-gonic/gin/...

# Create workspace
$ mkdir -p $HOME/go/src/gin-app
$ cd $HOME/go/src/gin-app

# Create server.go
$ vim server.go
```

> server.go
``` go
package main

import "github.com/gin-gonic/gin"

func main() {
    r := gin.Default()
    r.GET("/", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "message": "Hello, World!",
        })
    })
    r.Run() // listen and serve on 0.0.0.0:8080
}
```

Start server

``` sh
$ go run server.go
```
