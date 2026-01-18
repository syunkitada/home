# vscode

- ドキュメント
  - https://code.visualstudio.com/docs

## 拡張機能

- https://marketplace.visualstudio.com/items?itemName=GitHub.copilot
- https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode
- https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio
- https://marketplace.visualstudio.com/items?itemName=vscodevim.vim

### Markdown関連

- https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
- https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid
- https://marketplace.visualstudio.com/items?itemName=corschenzi.mermaid-graphical-editor

### タスク管理

#### Portable Kanban

- https://marketplace.visualstudio.com/items?itemName=harehare.portable-kanban
- json フォーマンで kanban 管理できる（拡張子は.kanban）
- kanban ファイルはどこにでも配置可能で、開けば kanban の UI で表示できる

#### Simple Kanban Board

- https://marketplace.visualstudio.com/items?itemName=te-dev.kanban-board
- json ファイルでメタデータを管理し、カードを md ファイルで管理している
- .vscode-kanban というディレクトリが workspace に作成され、cards ディレクトリ

```
.vscode-kanban/
  cards/
    /mkxxx.md
    /mkyyy.md
  index.json
```
