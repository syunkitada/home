# tmux

- nested tmux について
  - nested tmux とは、踏み台サーバで tmux を起動し、そこからの ssh 先でさらに tmux を起動させて、nested で tmux を利用することを言います
    - これが世間一般的なことかは不明だが、自分はこのような使い方をすることがあり、このことを nested tmux と呼んでいます
  - 独自用語として、踏み台で起動する tmux のことを under tmux と呼び、その先で起動する tmux のことを over tmux と呼びます
  - 両者の違いは、起動コマンドと、操作プレフィックスが異なるだけです
    - under tmux は、tt で起動し、この tmux の操作プレフィックスは、LALT + u です
    - over tmux は、t で起動し、この tmux の操作プレフィックスは、LALT + o です

## keytable について

- tmux の key table は、 3 種類ある
  - prefix
    - bind [key] [action...] で設定し、[prefix key]を押した後に、[key] を押すことで、[action]が実行される
    - 例: bind h select-pane -L
  - root
    - bind -n(-T root) [key] [action...] で設定し、[key]を押すと、[action]が実行される
    - 例: bind -n C-t new-window
  - copy-mode, copy-mode-vi
    - bind -T copy-mode [key] [action...] で設定する
- 独自の key table
  - bind -T [table] [key] [action..] で独自の key table でバインドを定義することができる
  - テーブル切り替えは、set key-table [table] で行う
- 参考
  - [Tmux in practice: local and nested remote tmux sessions](https://www.freecodecamp.org/news/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795/)
  - [Binding Keys in tmux](https://www.seanh.cc/2020/12/28/binding-keys-in-tmux/)

## tmux の描画が遅いメモ

- tmux 上のパネルで nvim を開いてる場合に描画が極端に遅くなることがある
  - おそらく nvim の描画のせい？
- visual mode は特に重くなるので、[prefix]+z で一画面でやるとよい
  - 極端な症状としてはカーソルがちかちかするような状態となる（tmux のタブをいったん切り替えるとなおる）

以下を nvim で設定するとある程度改善する？

```
set lazyredraw " マクロの途中で画面を再描画しない
set ttyfast " スクロール時に再描画するようにする
set nocursorline " カーソルラインをハイライトしない（描画コストが高いため）
```

プラグインが原因の場合もあるので、以下で vim プラグインを無効にしてみるとよい

```
vim -u None
```
