# vim script

## 関数の命名規則

```
" グローバル関数
function! Global()
    echo "global function"
endfunction


" スクリプトローカル関数
function! s:script_local()
    echo "script local"
endfunction


" autoload 関数
" runtimepath の autoload に置かれているスクリプトファイルで定義される
" 呼び出し方はグローバル関数と同じ
" autoload/hoge/foo.vim で定義するのであれば
function! hoge#foo#bar()
    echo "script local"
endfunction


" 辞書関数
" 辞書からクラスメソッドのような形で呼び出すことが出来る関数
let dict = {}
function! dict.func()
    echo "dict function"
endfunction
call dict.func()
```

## キーマッピング

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

## 参考

- [チートシート](https://devhints.io/vimscript)
- [Vim script の関数名について](https://osyo-manga.hatenadiary.org/entry/20130210/1360492784)
