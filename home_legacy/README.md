# 古い環境用のhomeディレクトリ用の設定ファイル郡

## Index

| Link | Description |
| --- | --- |
| [.bash_profile](.bash_profile) | Bashのログイン設定です。 |
| [.tmux.conf](.tmux.conf) | tmuxの設定です。 |
| [.zshrc](.zshrc) | zshの設定です。 |
| [Makefile](Makefile) | ドットファイルのリンク生成です。 |

以下のツール郡がインストールされた環境を想定しています。

```
$ rpm -qa | egrep 'tmux|zsh|bash'
bash-4.2.46-34.el7.x86_64
tmux-1.8-4.el7.x86_64
zsh-5.0.2-34.el7_8.2.x86_64
```

以下のコマンドで各種ドットファイル郡のシンボリックリンクをhomeディレクトリに生成します。

```
$ make
```
