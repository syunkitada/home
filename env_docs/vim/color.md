# color

- TrueColor を前提とする

## TrueColor の設定

- ターミナルでの色は二種類ある
  - 8-bit color
    - 一般的に利用されるもので、256 色(8-bit)で色表現できる
  - TrueColor
    - #ffffff で色表現できる

どちらが利用されてるかは以下で確認できます

```
$ curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash
```

TrueColor の利用方法

- ターミナル設定
  - 基本的に対応されているので設定する必要はない
- シェル(zsh)の設定
  - 基本的に対応されているので設定する必要はない
  - 以下のように TERM を設定すると 8bit にすることもできます
    - export TERM='xterm-256color'
- tmux の設定
  - set-option -g default-terminal "tmux-256color" # 基本的には screen-256color か tmux-256color を設定
  - set-option -ga terminal-overrides ",$TERM:Tc" # tmuxを起動していない時のzshでの$TERM の値を指定
- vim の設定
  - set termguicolors

## colorschema

- 今使ってるやつ
  - hybrid
    - 8bit でも綺麗ちゃんと描画されてた
    - 明るすぎず、暗すぎずちょうどよい
- 試しに使ってみるやつ
  - iceberg
    - [作者の紹介記事](https://cocopon.me/blog/2016/02/iceberg/)
    - hybrid に色感が似てる気がする
    - hybrid よりもクール（全体的に暗青系
- 選ぶ基準
  - 明るすぎず、暗すぎないこと
  - 背景が暗め
  - 渋すぎないこと（かっこ悪い）
    - hybrid はちょい渋い
  - 薄すぎないこと（ターミナルを半透明にしてもある程度見える）
  - 斜体(Itaric)を使ってないこと
- blacklist
  - folke/tokyonight.nvim
    - NG: func が Itaric
  - rebelot/kanagawa.nvim
    - NG: func が Itaric
  - ellisonleao/gruvbox.nvim
    - NG: 文字列が Itaric になる
  - ntk148v/vim-horizon
    - NG: コメントアウトが Itaric & 薄いので見ずらい
  - arcticicestudio/nord-vim
    - NG: 背景がちょい明るい

## 参考

- [vimcolorschemes](https://vimcolorschemes.com/)
- [TrueColor 対応のはなし(端末、シェル、tmux、vim)](https://www.pandanoir.info/entry/2019/11/02/202146)
