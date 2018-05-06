# net/httpによるシンプルなWebServer


``` go
package main

import (
    "net/http"
    "strings"
)

func hello(w http.ResponseWriter, r *http.Request) {
    message := r.URL.Path
    message = strings.TrimPrefix(message, "/")
    message = "Hello World!" + message
    w.Write([]byte(message))
}

func main() {
    http.HandleFunc("/", hello)
    if err := http.ListenAndServe(":8000", nil); err != nil {
            panic(err)
    }
}
```
