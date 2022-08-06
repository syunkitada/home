# nvim

## 初期セットアップ

```
python3
pip3 install pynvim neovim
pip3 install black
```

```
npm install prettier prettier/vim-prettier
```

- うまく初期化できない場合があるときは、以下も実行する

```
:UpdateRemotePlugins
```

## 方針、考え方のメモ書き

- Vim の利用目的は、コードリーディングとプログラミングを想定
- 共通で必要なもの
  - ファイルへの到達のしやすさ
    - ターミナル（zsh）から、ファイルへの到達のしやすさ
      - ファイル名を検索してのアクセス
        - ファイル名が分かってる場合に利用する
        - ファイルが存在するディレクトリ名が分かってる場合に利用する
      - ファイル内のテキストを検索してアクセス
        - コードリーディングなどでよく利用する
      - キャッシュから検索してアクセス
        - CPU の L1, L2 キャッシュの考えと同じで、直近利用したファイルは再度利用されやすい
        - バッファを L1 相当、ヒストリを L2 相当として、キャッシュからファイルを検索して開く
      - ブックマークから検索してアクセス
        - ファイルの編集中や、コードリーディング中など後で再度アクセスするであろうことがわかってる場合に利用する
        - プロジェクト単位でブックマークを管理したい
        - ファイルに対してというよりは行単位でブックマークする想定
    - Vim でファイルを開いた状態から、別ファイルへの到達のしやすさ
      - 大まかには、ターミナル（zsh）から、ファイルへの到達のしやすさと共通
        - これは、Vim の Terminal モードへ移行して、zsh で別ファイルへアクセスする想定
      - ファイル内のタグなどから関数などの定義元や参照元のファイルへたどる
    - ファイラ(Vim?)からファイルへの到達のしやすさ
      - 目的のファイル名やディレクトリ名があいまいな場合や、ディレクトリの構成把握ができてない場合に便利
      - ディレクトリ・ファイル構成が視覚的に覚えやすい
      - 目的のファイル名が分かっている場合も hjkl でファイルを選択できて楽な場合もある
        - ただしこれは直近開いたファイルと目的のファイルが隣接してる場合に限る
      - ファイラ使わずにうまくターミナルだけでやりたさはある（改善できるかも？）
        - CLI においてファイラに頼ったファイルアクセスは遅い？気がする
  - リファレンスの参照
    - 自分用の doc を参照できるようにしておく
- プログラミングで必要なもの
  - 入力補完
    - 必須ではないがあると便利
    - LSP による補完が一般的
    - 各言語ごとに LSP サーバや設定を行う必要がある
  - フォーマット機能
    - 必須
    - 各言語ごとにプラグインがあるのでそれを入れる
  - メタ情報の表示
    - シンタックスエラーの表示
      - 必須ではないがあると便利
      - フォーマット機能を入れてればある程度カバーできる
    - git の diff 表示
      - 必須ではないがあると便利

## 補完、LSP まわり

- 結論
  - LSP クライアントは、Neovim に標準でついてるのでそれを使うのがよさそう
  - 補完用のプラグインは別途用意する
- LSP
  - メモ
    - LSP はサーバ側、クライアント側で分かれており、vim にはクライアント側の実装を入れる必要がある
    - LSP サーバは各言語ごとに存在し、必要に応じてインストールする必要がある
      - 依存のインストールをプラグインがサポートしてる場合もあるが、必須ではない
        - これは個人的な好みだが依存を意識したいので、このようなプラグインは使わない
  - [vim-lsp](https://github.com/prabirshrestha/vim-lsp)
    - これが広く使われてそう？
    - [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings)
      - vim-lsp 単体でもいいが、設定や依存のインストールを簡易化できる
  - [coc](https://github.com/neoclide/coc.nvim)
    - [Neoclide プロジェクト][https://github.com/neoclide]の一つ
      - 以前少し利用したが動作が不安定で利用をやめた
      - プロジェクトの説明に IDE based on neovim とあるように、IDE の機能を coc ベースに移植してるっぽい
        - 既存プラグインを coc ベースに書き換えて移植とかもしてる？
  - nvim-lsp
    - Neovim(0.5 以上) で利用可能な LSP クライアント
      - 要求バージョンが高いのでいったん見送り
    - 参考
      - [Neovim builtin LSP 設定入門](https://zenn.dev/nazo6/articles/c2f16b07798bab)
      - [[第 13 回] Neovim のすゝめ – LSP をセットアップ（Builtin LSP 編）](https://wonwon-eater.com/nvim-susume-builtin-lsp/)
- 補完まわり
  - [deoplete.nvim](https://github.com/Shougo/deoplete.nvim)
    - 長年お世話になっていたが、開発が止まってるので他のに切り替える
  - [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
    - nvim-lsp 連携できる
  - [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
    - 参考
      - [asyncomplete.vim を使い始めた](https://qiita.com/hokorobi/items/b4be36253262373fbefc)
  - [ddc.vim](https://zenn.dev/shougo/articles/ddc-vim-beta)
    - ddc.vim を利用するには Vim 8.2.0662 以上または neovim 0.5.0 以上が必要、Deno も必要
    - 参考
      - https://github.com/Shougo/ddc-nvim-lsp
      - ddc.vim で使う例 [Vim の新しい自動補完プラグイン「ddc.vim」を使ってみた](https://note.com/dd_techblog/n/n97f2b6ca09d8)

## ファイラまわり

- 結論
  - Fern がよさそう
- [vimfiler](https://github.com/Shougo/vimfiler.vim)
  - デフォルトの機能が豊富で、キーバインドも使いやすくてとても良い（長年お世話になってた）
  - 一応動く程度のメンテはされてるが、開発は止まってる
- [defx.nvim](https://github.com/Shougo/defx.nvim)
  - vimfiler の後継らしい（使ったことはない）
  - 一応動く程度のメンテはされてるが、開発は止まってる
- [ddu-ui-filer](https://github.com/Shougo/ddu-ui-filer)
  - ddu.vim のプラグイン的な立ち位置？
  - ddu.vim の UI をファイラ風にしたもの
  - ファイラに必要な機能自体は ddu.vim に実装されている
  - ddu.vim 込みでカスタマイズ性はすごそうだが、カスタマイズすることが前提のため、少し敷居が高い
    - デファクトみたいな設定が出て来たら使うかもしれない
- [netrw](https://vim-jp.org/vimdoc-ja/pi_netrw.html)
  - vim デフォルトのファイラ
  - デフォルト設定が使いずらい
    - let g:netrw_liststyle = 3 とし(ツリー表示にして)、キーバインドも設定しなおせばまあまあ使えると思う
    - しかし、設定をいじったとしても操作感はやはり vimfiler のが使いやすいと思う
- [vaffle](https://github.com/cocopon/vaffle.vim)
  - [紹介記事](https://cocopon.me/blog/2017/01/vaffle/)
  - シンプルなファイラだが、このぐらいの機能なら netrw でよいかも
  - ディレクトリの展開表示ができない？
- [NERDTree](https://github.com/preservim/nerdtree)
  - よく見かけるけど、実はあまり使ったことがない
  - 以前導入しかけたときは、vimfiler のが使いやすい結論付けて止めた
  - 作成者は引退して新しいメンテナーを募集している（良い意味）
    - https://github.com/preservim/nerdtree/issues/1280
    - プロジェクトにファンがいて受け継がれているので信頼できる
- [fern](https://github.com/lambdalisue/fern.vim)
  - [紹介記事: 2020 秋 Vim のファイラー系プラグイン比較](https://zenn.dev/lambdalisue/articles/3deb92360546d526381f)
  - 機能とキーバインドが理想に近い(vimfiler にデフォルトの使用感が近い)
    - ちょっとキーバインドいじるだけで良さそう
  - 依存がない
  - プラグインで拡張できる
    - https://github.com/topics/fern-vim-plugin
    - project の top に移動するやつ
      - https://github.com/lambdalisue/fern-mapping-project-top.vim
  - 参考
    - https://wonwon-eater.com/neovim-susume-file-explorer/

## バージョン問題

- [1 度ビルドした Neovim を他のマシンにコピーしたい: 動的リンクライブラリを静的リンクにし直す「sold」リンカ](https://logmi.jp/tech/articles/326142)
