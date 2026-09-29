# User

## Special Linux UIDs

- 0: root
- 1-999: system user
  - デーモンプロセスが利用するためのIDです
  - 各ディストリビューションでuidは異なり、その管理の仕方も異なる
  - 予約済みの番号もあるし、自動アサインもある
- 1000-65534: free space
  - ユーザが自由に採番して利用してよい
- 65534: nobody
  - 必要最低限の権限のみを持つユーザで、rootの対極にあり、rootと同様デフォルトで作成されています
  - 必要最低限の権限のみを持つことが想定されており、nobodyに追加の権限を与えて利用してはいけません
- 65535: unavailable
- 65536-4294967295: free space
  - ユーザが自由に採番して利用してよい

# References

- https://docs.rockylinux.org/books/admin_guide/06-users/
- https://systemd.io/UIDS-GIDS/
