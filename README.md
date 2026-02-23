# Home

This repository manages my personal configuration files and documents.

## Initial setup procedures for each OS

- [Setup Windows](docs/env/os/windows/README.md)
- [Setup CentOS](docs/env/os/centos/README.md)
- [Setup Ubuntu](docs/env/os/ubuntu/README.md)

```
# Initial setup procedures for shell(except windows)
$ make setup
$ make check
```

Change the default shell to zsh.

```
$ sudo chsh -s $(which zsh) $(whoami)

# After changing the shell, you need to log out and log in again to apply the changes.
# After logging in again, you can check if the shell is changed by running the following command:
$ echo $SHELL
```

If the shell is not changed, you can check the following points:

```
# 1. Check if the shell is changed
$ grep $(whoami) /etc/passwd

# 2. Check if the ssh session is still active.
# If you are using ssh session sharing as bellow, you need to close the ssh session and log in again to apply the changes.
#   .ssh/config
#   ControlMaster auto
#   ControlPath ~/.ssh/mux-%n
#   ControlPersist 3600
$ ssh -O exit <your ssh host>
```

## Contents

| Link                                         | Description                                                  |
| -------------------------------------------- | ------------------------------------------------------------ |
| [docs](docs/README.md)                       | 雑多なドキュメント類です。                                   |
| [dotfiles](dotfiles/README.md)               | $HOME に配置するドットファイル群です。                       |
| [xdgconfig](xdgconfig/README.md)             | $XDG_CONFIG_HOME に配置するファイル群です。                  |
| [legacy_dotfiles](legacy_dotfiles/README.md) | 古い環境用の最小限の設定のためのドットファイル群です。       |
| [playground](playground/README.md)           | 設定ファイルの動作を確認するための実験環境構築ツール群です。 |
| [etc](etc/README.md)                         | 雑多なファイル群です。                                       |
| [scripts](scripts/README.md)                 | 雑多なスクリプトファイル群です。                             |

## About home_ex

You can use home_ex as a repository to manage external configuration and docs.

```
$ git clone <your external respository> ~/home_ex
```

The following files are supported:

```
home_ex/
  docs/
    cmd/  <-- For managing docs of command line tools
      *.md
    ops/  <-- For managing docs of operations
      *.md
  xdgconfig/
    zsh/  <-- The configuration files are loaded by zsh
      *.zsh
```
