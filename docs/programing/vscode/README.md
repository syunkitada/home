# vscode

- ドキュメント
  - https://code.visualstudio.com/docs
- tmux + vim 環境と比べての所感
  - ジャンプ機能は ctags よりも優秀
  - コードリーディングにはとても向いてそう
  - terminal での処理に若干ラグがある

## windows での SSH の設定

- 秘密鍵は home のドキュメントに置いておく
  - 適当に作ったフォルダだと権限が広すぎて怒られる
- サービス設定で OpenSSH Authentication Agent を起動しておく(自動起動に設定しておく)
- PowerShell かコマンドプロンプトで以下のコマンドを実行する
  - ssh-add [秘密鍵のパス]

## Extensions

- Vim
  - 標準で easymotion などの機能も付いてくる
  - Extension に設定項目が書いてあるので設定する(TODO)
- Remote Development
  - リモート環境上にも VsCode をインストールして利用できる
  - リモート環境上に vscode サーバが立ち上がってる
  - ファイルを単に編集してるのか、
  - TERMINAL もリモート上で使える(Default Shell を zsh にしておくとよい)
  - TERMINAL 上で code [filepath]を実行すると vscode 上でファイルが開く
  - tmux なども普通に使える
  - 表示にはラグがあるので通常のターミナルとして使うのはつらそう
- Prettier
  - Formatter

## Shortcut

- 各パレットのショートカットは把握しておく
- 設定
  - outline.focus: Ctrl + Shift + f8
  - view: toggle maximized panel: Ctrl + Shift + f10

## 例外的な設定

- terminal.integrated.rendererType を auto ではなく、dom にする
  - auto だと terminal の横幅が狭くなってしまう
