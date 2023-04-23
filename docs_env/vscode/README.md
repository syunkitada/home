# vscode

- ドキュメント
  - https://code.visualstudio.com/docs

## Extensions

- Vim
  - 標準で easymotion などの機能も付いてくる
  - Extension に設定項目が書いてあるので設定する(TODO)
- Remote Development
  - リモート環境は、SSH、WSL が利用できる
  - リモート環境上にも VsCode をインストールされる
  - TERMINAL もリモート上で使える(Default Shell を zsh にしておくとよい)
  - TERMINAL 上で code [filepath]を実行すると vscode 上でファイルが開く
  - tmux なども普通に使える
  - 表示にはラグがあるので通常のターミナルとして使うのはつらそう
- Prettier
  - Js, TypeScriptなどのFormatter
- Go
  - WSL上でvscode上が実行できるPATHにgoを配置しておく必要がある
  - sudo ln -s /home/owner/.goenv/shims/go /usr/local/bin
  - プラグインを有効化したときに、go toolsがインストール(go get)される
  - https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on
  - LanguageServerは、goplsがよい？

## PreviewMode について

- ファイルをシングルクリックで開くと PreviewMode でタブに表示される(タブのファイル名が Italic になってる)
  - Vim モードでは l or Enter でファイルを開く
- PreviewMode タブがある状態で別のファイルを開くと、新規のタブではなく PreviewMode タブでファイルが開かれる
- ファイルに書き込むと、PreviewMode が解除される
- 不要であれば以下の設定で無効化できる
  - "workbench.editor.enablePreview": false,

## ショットカットの設定

- 手動設定(設定ファイルではできない?)
  - Ctrl + Shift + f8: outline.focus
  - Ctrl + Shift + f10: view: toggle maximized panel
- Autohotkey
  - RShift + e: open exproler
  - RShift + g: focus editor1
  - RShift + h: focus editor2
  - RShift + o: focus outline
  - RShift + j: jump to definition
  - RShift + k: jump to previous
  - RShift + h: jump to forward
  - RShift + t: open terminal window
  - RShift + f: open terminal window and toggle full terminal window
  - RShift + s: search file
  - RShift + r: grep file

### terminal.integrated.rendererType

- terminal のレンダリング設定
- auto だと terminal の横幅が狭くなってしまうので dom にする