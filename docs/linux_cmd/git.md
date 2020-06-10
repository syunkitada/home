# git

## あるリポジトリの修正を別のリポジトリに適用する

- リポジトリ A とリポジトリ B を並行運用するときに、リポジトリ A に適用したコミットをリポジトリ B にも適用する場合を想定

```
# patchを作成する
$ cd ~/repository1

$ mkdir /tmp/patches
# 特定コミットからパッチを作成する
$ git format-patch -o /tmp/patches 34ece0dbc9bca5b028e677bfe17e157359047b30
/tmp/patches/0001-update.patch
/tmp/patches/0002-update.patch


# 別のリポジトリに適用する
$ cd ~/repository2
$ git am -3 patches/*.patch
```
