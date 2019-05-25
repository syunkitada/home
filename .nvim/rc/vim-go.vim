" vim-go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

let g:go_fmt_autosave = 1  " ファイル保存時にfmtで自動整形する

" fmtをgoimportsに置き換える、goimportsは自動整形に加えて自動でimport宣言を追加する
" 重くなる場合は、無効化し:GoImports で明示的に実行するといい
let g:go_fmt_command = "goimports"

let g:go_metalinter_autosave = 1 " ファイル保存時にmetalinterを実行する
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck'] " :GoMetaLinter実行時に実行されるlintを設定できる
let g:go_metalinter_autosave_enabled = ['vet'] " ファイル保存時に実行されるlintを設定できる、golint, errcheckは実行に時間がかかるため無効にする
let g:go_metalinter_deadline = "10s" " metalinterの実行時間が長い時は指定した時間でキャンセルする
" lintチェックは、別でやったほうが良さそう
" let g:go_metalinter_command = "gometalinter --config=" . $HOME . "/.config/gometalinter/config.json"
" let g:go_metalinter_command = "gometalinter --config=/home/owner/.config/gometalinter/config.json"
" let g:go_metalinter_options = "--config=/home/owner/.config/gometalinter/config.json"
" let g:ale_go_gometalinter_options = "--config=/home/owner/.config/gometalinter/config.json"
" let g:ale_go_gometalinter_executable = 'gometalinter'
" let g:go_metalinter_command = "golangci-lint"
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
" let g:syntastic_go_checkers = ['golint', 'govet', 'gometalinter']
" " let g:syntastic_go_gometalinter_args = ['--config=/home/owner/.config/gometalinter/config.json']
" let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }


" -------------------------
" motion
" -------------------------
" [dvy]if 関数内(宣言を含まない)を指定
" [dvy]af 関数丸ごと(宣言、GoDocを含む)を指定
" [[ 前の関数にジャンプ
" ]] 次の関数にジャンプ


" -------------------------
" コマンドメモ
" -------------------------

" :GoTest
" go testを実行する

" :GoTestFunc
" フォーカスしてる関数のみをテストする

" :GoCoverage
" カバレッジ表示

" :GoAlternate
" テストファイルと非テストファイルを行き来きする
nmap [vimgo]a :GoAlternate<CR>

" :GoDef, :GoDefPop, :GoDefStack
" 変数の宣言場所にジャンプする, Popで戻る, Stackでジャンプのスタックを開いてジャンプ
nmap [vimgo]d :GoDef<CR>
nmap [vimgo]f :GoDefPop<CR>
nmap [vimgo]s :GoDefStack<CR>

" :GoDecls
" 関数定義一覧を表示

" :GoDeclsDir
" そのディレクトリ内の関数定義一覧を表示

" GoDoc, ノーマルモードでK で閲覧できる

" GoSameIds
" 同じ識別子をハイライトする(スコープも意識する)

" :GoReferrers
" 関数の参照元を表示する

" :GoDescribe
" 構造体のメソッド一覧を表示してくれる

" :GoImplements
" 構造体のインターフェイスを表示

" :GoRename [str]
" カーソルの識別子をrenameする

" :GoFreevars
" 領域内の変数で参照されているものを表示する
" 一部の処理を外だししたい場合に便利

" :GoImpl [interface]
" 指定したインターフェイスを実装したひな型コードを自動生成する
