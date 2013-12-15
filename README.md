home
====

ホームディレクトリの設定ファイルなど。

以下のスクリプトで、.bashrcなどの設定ファイルのシンボリックリンクをホームディレクトリに貼ります。

for Cent OS

    $ setup_cent.sh
    
    # ついでに、git clone https://github.com/Shougo/neobundle.vim.git も行います

for Windows

    setup_win.bat をダブルクリック
    
    # setup_win.batでは、neobundleのgit cloneは行いません
    # 別途、homeディレクトリで以下を行う必要がある
    git clone https://github.com/Shougo/neobundle.vim.git .vim/bundle/neobundle.vim/

