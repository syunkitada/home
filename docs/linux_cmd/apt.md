# apt

## パッケージ検索

```
$ apt-cache search libibver
```

## インストール済みのパッケージ検索

```
$ dpkg -l
```

- ii: インストール済み
- iU: インストール済み
- rc: 設定ファイルだけ残ってる状態
  - 以下で設定ファイルも含めてすべて削除できる
  - sudo apt remove --purge packagename

## History

```
$ less /var/log/apt/history.log
/usr/bin/unattended-upgrade
```

## Disable downloading translations

```
$ cat <<EOF | dd of=/etc/apt/apt.conf.d/99translations
Acquire::Languages "none";
EOF
```

## Auto upgrades

- 自動更新の除外設定

```
$ vim /etc/apt/apt.conf.d/50unattended-upgrades
// List of packages to not update (regexp are supported)
Unattended-Upgrade::Package-Blacklist {
    "vim";
//>_"libc6";
//>_"libc6-dev";
//>_"libc6-i686";
};
```

## Add repository

```
$ cat <<EOF | dd of=/etc/apt/sources.list.d/syunkitada-aptrepo.list
deb [trusted=yes] http://hogepiyo/hoge/amd64/ ./
EOF
```
