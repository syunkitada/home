# echo


## References
* https://echo.labstack.com/guide


## Hello World
``` sh
$ echo $GOPATH
/home/owner/go

# Install
$ go get -u github.com/labstack/echo/...

# Create workspace
$ mkdir -p $HOME/go/src/echo-app
$ cd $HOME/go/src/echo-app

# Create server.go
$ vim server.go
```

> server.go
``` go
package main

import (
    "net/http"
    
    "github.com/labstack/echo"
)

func main() {
    e := echo.New()
    e.GET("/", func(c echo.Context) error {
        return c.String(http.StatusOK, "Hello, World!")
    })
    e.Logger.Fatal(e.Start(":1323"))
}
```

Start server

``` sh
$ go run server.go
```
