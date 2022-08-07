# MEMO

- map: ノーマルモード、ビジュアルモード用のキーマッピング
- nmap: ノーマルモード用のキーマッピング
- vmap: ビジュアルモード用のキーマッピング
- imap: インサートモード用のキーマッピング
- cmap: コマンドライン用のキーマッピング
- noremap 系(nnoremap など): マッピングの伝番を防ぐキーマッピング

```
# 以下は、<F1>を入力すると、<C-T>にはHelloがマッピングされてるので、Helloが入力される
:imap <C-T> Hello
:imap <F1> <C-T>


# 以下は、<F1>を入力すると、<<C-T>がそのまま実行される
:imap <C-T> Hello
:inoremap <F1> <C-T>
```

- 特殊引数
  - <silenct> を指定すると、実行するコマンドがコマンドラインに表示されないようにする
  - <buffer> カレントバッファだけで使用できるマップを作成する

```
# abort識別はエラーが発生した際に即時で関数を抜ける
function! s:fern_settings() abort
   ...
endfunction
```

[チートシート](https://devhints.io/vimscript)
