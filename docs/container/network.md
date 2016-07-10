# network

https://docs.docker.com/engine/tutorials/networkingcontainers/

linuxbridgeみたいにコンテナもブリッジ経由で接続されている
```
$ sudo docker network ls
[sudo] password for fabric:
NETWORK ID          NAME                DRIVER
4c4c8f84be04        bridge              bridge
6434892663a3        host                host
f8c41f29df78        none                null

$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "4c4c8f84be045665d3796f8d16cd99322724a3e0119c9eb143430eab8f160b29",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16"
                }
            ]
        },
        "Internal": false,
...
]
```
