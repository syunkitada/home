# git

[DOC] ソースコードなどのバージョン管理システムです

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

## 空のディレクトリを無視するための二つのパターン

- .gitignore を使うパターン
  - ディレクトリにファイルを追加する予定がない場合、間違って追加されても無視したい場合は以下のような.gitignore を追加する

```
*
!.gitignore
```

- .gitkeep を使うパターン
  - ディレクトリにファイルを追加する予定がある場合、.gitkeep(ただの空ファイル) を置く
  - .gitignore を置いておくでもよいが、用途ととして紛らわしいので.gitkeep を置くほうが好まれる

## git submodule

- git submodule は master ブランチの HEAD を自動追尾するものではない
  - あくまで別リポジトリのコミット（リビジョン）を参照してるだけ
  - サブ側が更新されたら、親側でも明示的に参照先を更新する必要がある
- git submodule を使うべきかどうか？
  - git submodule を使う場面は意外と少ない
    - プロジェクトが大きくなったからといって git submodule で分割するのは間違い
  - 開発チームが分かれており、module 単位で開発したいなどがあれば、利用検討の余地がある
    - master 追従が自動できないので、submodule 化せずに単に プロジェクトを分けて clone して取り込むほうが良い場合もある

```
# submoduleの追加
$ git clone git@github.com:syunkitada/test.git
$ cd test
$ git submodule add git@github.com:syunkitada/test-samples.git
$ git commit -am 'add submodule'
$ git push
```

```
# submoduleごとgit cloneする
$ git clone git@github.com:syunkitada/test.git --recursive
```

```
$ git clone git@github.com:syunkitada/test.git
$ cd test

# git cloneしたあとに(--recursiveをつけ忘れたなど)、submoduleを取得する
$ git submodule update --init

# 他の人がsubmodule側を更新していた場合なども同様
$ git pull
$ git submodule update --init
```

```
# submoduleの状態、参照先を確認する
$ git submodule foreach git fetch
Entering 'test-samples'

$ git submodule status
 f3603e5e4aa14f1ae0aa0d461a5bcd485192e72a test-samples (heads/master)
```

```
# submodule側を更新する
$ cd test-sample
$ vim xxx
$ git add xxx
$ git commit -m 'xxx'
$ git push -u origin [HEAD]

# 親側を更新する
$ git add test-sample/xxx
$ git commit -m 'xxx'
$ git push origin [HEAD]
```

```
# submoduleのリビジョンを変更する
$ cd test-sample
# 適当なコマンドでサブモジュール側を更新する（チェックアウトする）
$ git pull origin master
# 親側に戻る
$ cd ../
$ git add test-sample
$ git commit -m 'xxxx'
$ git push
```

```
# submoduleを削除する（submoduleの情報が複数にあるので少し大変）
$ git submodule deinit -f test-samples
$ git rm -f test-samples
$ rm -rf .git/modules/test-samples
$ git commit -m 'remove submodule'
$ git push
```

## git tag

- git tag は、あるブランチの特定のコミットに名前をつけるためのものです。
- mainブランチの特定のコミットに名前をつけることで、リリースバージョンなどを管理するのに使われることが多いです。
- タグは、リモートリポジトリにプッシュすることができます。
- また、タグのプッシュは、ブランチに対して行われるものではなく、リポジトリに対して行われるため、リモートリポジトリ側で適切に制限をかけておくことが重要です。
  - 特に、上書きや削除に関しては制限をかけておくことが推奨されます。

```
# タグを作成する
$ git tag v1.0.0

# タグをリモートリポジトリにプッシュする
$ git push origin v1.0.0

# すべてのタグをリモートリポジトリにプッシュする
$ git push --tags

# タグを削除する
$ git tag -d v1.0.0

# リモートリポジトリからタグを削除する
$ git push origin :refs/tags/v1.0.0
```
