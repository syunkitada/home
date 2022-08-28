# lsp

- nvim-lsp の利用を前提とする

## 言語ごとの LSP、フォーマッタ、リンタ

- nvim-lspconfigで利用可能なLSP は以下を参考に
  - https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
- null-lsで利用可能なツールは以下を参考に
  - https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
- python
  - LSP: pyright
  - Formater: black
  - Linter: flake8
- web系全般
  - LSP: tailwindcss
  - Formatter: prittier
  - Linter: ?
- clang
  - LSP: clangd
  - Formatter: [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html)
  - Linter: ?
- golang
  - LSP: gopls
  - Formatter: goimports
  - Linter: [golangci-lint](https://github.com/golangci/golangci-lint)
- rust
  - LSP: ?
  - Formatter: ?
  - Linter: ?

## nvim-lspと関連プラグインについて

- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  - LSP 設定用のプラグイン（公式）
  - 最低限のことはこれだけでできる
  - そのままだと不便なので操作性拡張のためにプラグインを別途導入するほうが良い
  - [nvim-lspconfig使ってみたメモ](nvim-lspconfig.md)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
  - 補完機能用のプラグイン(nvim-lsp をソースとして補完できる)
  - nvim-comは、補完機能のためのプラグインです
  - cmp-xxxは、保管ための情報源(source)を提供するためのプラグインです
    - [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): bufferの文字をsourceとして提供する
    - [cmp-path](https://github.com/hrsh7th/cmp-path): ファイルシステムパスをsourceとして提供します
    - [cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline): vimのコマンドラインをsourceとして提供します（不要かも？）
    - [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): lspをsourceとして提供します
  - hrsh7th/cmp-vsnip, hrsh7th/vim-vsnip は、スニペットのためのプラグインです
- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) -フォーマッタ・リンタ
  - 様々なツールを LSP の形式に変換して nvim-lsp に送る仕組みになっている
    - これにより flake8 や black などの CLI ツールを利用できる
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)
  - 言語サーバのステータス表示
- [lspsaga.nvim](https://github.com/glepnir/lspsaga.nvim)
  - リッチな UI を提供してくれる
    - 定義元、参照先の一覧表示
    - アウトライン表示
  - このプラグインの利用は注意が必要で、ある時期（2021/05 ぐらい？）から作者が不在になっていくつかのフォークが生まれてプロジェクトが分離している
    - https://github.com/glepnir/lspsaga.nvim/network/members
  - https://github.com/kkharji/lspsaga.nvim
    - kkharji/lspsaga.nvim もその一つである
    - しかし、元の作者が（2022/06 ぐらい？から）復帰しており、フォークされたプロジェクトが今後どうなるかは不明である
      - https://github.com/kkharji/lspsaga.nvim/issues/123

## その他の選択肢

- [vim-lsp](archived/vim-lsp.md)
- [coc](archived/coc.md)
