# patch

[DOC] テキストファイルに patch ファイル(差分ファイル)を適用するためのコマンド

- patch ファイルは diff, git diff, git format-patch などで出力したものをそのまま利用できる

```
# dir配下全て対象にpatchを適用する
$ cd [dir]
$ patch -p 1 < [patchfile]


# 特定のファイルにpatchを適用する
$ patch [targetfile] [patchfile]
```
