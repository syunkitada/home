# keybind basic

## 移動系

```
[KEYBIND] mode=vn; key=gg; tags=move; action=一番上に移動します;
[KEYBIND] mode=vn; key=G; tags=move; action=一番下に移動します;
[KEYBIND] mode=vn; key=[num]G; tags=move; action=[num]行に移動します;
[KEYBIND] mode=vn; key=h; tags=move; action=左へ移動します;
[KEYBIND] mode=vn; key=j; tags=move; action=下へ移動します;
[KEYBIND] mode=vn; key=k; tags=move; action=上へ移動します;
[KEYBIND] mode=vn; key=l; tags=move; action=右へ移動します;
[KEYBIND] mode=vn; key=H; tags=move; action=画面上へ移動します;
[KEYBIND] mode=vn; key=L; tags=move; action=画面下へ移動します;
[KEYBIND] mode=vn; key=-; tags=move; action=前の文頭に移動します;
[KEYBIND] mode=vn; key=<Enter>; tags=move; action=次の文頭に移動します;
[KEYBIND] mode=vn; key=f[char]; tags=move; action=カーソル後の一行から[c]を検索して移動します;
[KEYBIND] mode=vn; key=t[char]; tags=move; action=カーソル後の一行から[c]を検索して、その手前まで移動します;
[KEYBIND] mode=vn; key=F[char]; tags=move; action=カーソル前の一行から[c]を検索して移動します;
[KEYBIND] mode=vn; key=T[char]; tags=move; action=カーソル前の一行から[c]を検索して、その手前まで移動します;
[KEYBIND] mode=vn; key=0; tags=move; action=カーソル行の一番前に移動します;
[KEYBIND] mode=vn; key=$; tags=move; action=カーソル行の一番後ろに移動します;
[KEYBIND] mode=vn; key=/[str...]; tags=move; action=単語を下に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=?[str...]; tags=move; action=単語を上に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=#; tags=move; action=カーソル位置の単語を完全一致で上に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=g#; tags=move; action=カーソル位置の単語を上に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=*; tags=move; action=カーソル位置の単語を完全一致で下に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=g*; tags=move; action=カーソル位置の単語を下に検索します(n/Nで前/次の検索結果に移動します);
[KEYBIND] mode=vn; key=%; tags=move; action=カーソル位置の括弧のペアの括弧に移動します;
```

## 編集

```
[KEYBIND] mode=vn; key=x; tags=edit; action=カーソル位置の文字を削除します;
[KEYBIND] mode=vn; key=d[move cmd]; tags=edit; action=[move]対象の文字を削除します;
[KEYBIND] mode=vn; key=D; tags=edit; action=カーソル後ろの一行を削除します;
[KEYBIND] mode=vn; key=c[move cmd]; tags=edit; action=[move]対象の文字を削除し、入力モードに切り替えます;
[KEYBIND] mode=vn; key=C; tags=edit; action=カーソル後ろの一行を削除して入力モードに切り替えます;
[KEYBIND] mode=vn; key=r; tags=edit; action=(replace)カーソル位置の文字を置換します;
[KEYBIND] mode=vn; key=u; tags=edit; action=(undo)一つ前の操作を取り消します;
[KEYBIND] mode=vn; key=R; tags=edit; action=(redo)undoで取り消した操作をやり直します;
```

## ファイル操作

```
[KEYBIND] mode=vn; key=:e[path]; tags=file; action=[path]のファイルを現在のタブで開きます;
[KEYBIND] mode=vn; key=:tabe[path]; tags=file; action=[path]のファイルを新しいタブで開きます;
[KEYBIND] mode=vn; key=:e!; tags=file; action=現在のタブのファイルを開きなおします;
```
