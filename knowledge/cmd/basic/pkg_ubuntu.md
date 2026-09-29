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

システム設定ファイルを書き換えるため、管理者権限が必要です。

```
$ sudo tee /etc/apt/apt.conf.d/99translations >/dev/null <<'EOS'
Acquire::Languages "none";
EOS
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

APTリポジトリは、HTTPSと署名検証を利用してください。`trusted=yes` は署名検証を無効にするため使用しません。リポジトリ提供元の手順で署名鍵を `/etc/apt/keyrings/` に配置し、`signed-by` で明示します。

```
$ sudo tee /etc/apt/sources.list.d/syunkitada-aptrepo.list >/dev/null <<'EOS'
deb [signed-by=/etc/apt/keyrings/syunkitada-aptrepo.gpg] https://example.invalid/hoge/amd64/ ./
EOS
```

## PPA

- Personal Package Archive の略
- Ubuntu 向けの個人用リポジトリで、Launchpad.net にソースパッケージをアップロードすると、APT リポジトリとしてリリースできる
- Ubuntu ユーザーは公式リポジトリに登録されていないパッケージをインストールすることが可能
