# lazygit

- [lazygit](https://github.com/jesseduffield/lazygit)
- git 操作のためのリッチな UI です

## keybind

```
# グローバル
[KEYBIND] key=?; tags=show; action=ヘルプを表示します
[KEYBIND] key=h; tags=move; action=前のパネルへ移動します
[KEYBIND] key=l; tags=move; action=次のパネルへ移動します
[KEYBIND] key=j; tags=move; action=カーソルを下へ移動します
[KEYBIND] key=k; tags=move; action=カーソルを上へ移動します
[KEYBIND] key=p; tags=edit; action=pullします
[KEYBIND] key=P; tags=edit; action=pushします
[KEYBIND] key=H; tags=edit; action=カレントパネルを左スクロールします
[KEYBIND] key=L; tags=edit; action=カレントパネルを右スクロールします
[KEYBIND] key=.; tags=edit; action=カレントパネルを次のページへ
[KEYBIND] key=,; tags=edit; action=カレントパネルを前のページへ
[KEYBIND] key=[; tags=edit; action=カレントパネルを前のタブへ
[KEYBIND] key=]; tags=edit; action=カレントパネルを次のタブへ
[KEYBIND] key=J; tags=edit; action=プレビューパネルを下へスクロールします
[KEYBIND] key=K; tags=edit; action=プレビューパネルを上へスクロールします
[KEYBIND] key=<Esc>; tags=move; action=戻る

# ファイルパネル
[KEYBIND] key=e; mode=gf; tags=move; action=ファイルをエディタで開きます
[KEYBIND] key=_; mode=gf; tags=mark; action=ファイルをステージ・アンステージします
[KEYBIND] key=a; mode=gf; tags=mark; action=すべてのファイルを変更ステージ・アンステージします
[KEYBIND] key=c; mode=gf; tags=edit; action=コミットします
[KEYBIND] key=C; mode=gf; tags=edit; action=gitの画面でコミットします
[KEYBIND] key=f; mode=gf; tags=edit; action=フェッチします
[KEYBIND] key=r; mode=gf; tags=edit; action=ファイルをリフレッシュします
[KEYBIND] key=i; mode=gf; tags=edit; action=ファイルをignoreします
[KEYBIND] key=<Enter>; tags=move; action=プレビューパネルに移動します

# ブランチパネル
[KEYBIND] key=n; mode=gb; tags=edit; action=新しいブランチを作成します
[KEYBIND] key=_; mode=gb; tags=edit; action=ブランチをチェックアウトします
[KEYBIND] key=d; mode=gb; tags=edit; action=ブランチを削除します
[KEYBIND] key=R; mode=gb; tags=edit; action=ブランチ名を変更します
```
