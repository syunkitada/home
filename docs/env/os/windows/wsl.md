## WSL(Ubuntu)

WIP

- Microsoft StoreからUbuntuをインストールしてください
  - バージョン固定されてるものではなく、無印のUbuntuをインストールしてください
- ターミナルヘッダを右クリックして、プロパティのオプションを開き、Ctrl+Shift+C/V によるコピペを有効にする

#### ssh の設定

1. "C:\Users\[User]\.ssh" のフォルダを、"C:\Users\[User]\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_XXX\LocalState\rootfs\home\[User]"にコピー
2. その後ターミナルから.ssh の権限を適切に変更する

```
$ sudo chown -R owner:owner .ssh
$ chmod 700 ~/.ssh/id_* ~/.ssh/config ~/.ssh/known_hosts
```

3. ssh-agent を起動

```
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;
SSH_AGENT_PID=89; export SSH_AGENT_PID;
echo Agent pid 89;
$ SSH_AUTH_SOCK=/tmp/ssh-XXXXXXXqFtJP/agent.88; export SSH_AUTH_SOCK;

$ ssh-add
```

#### shell のセットアップ

```
$ sudo apt install make
$ git clone git@github.com:syunkitada/home.git
$ cd home
$ make setup
```

#### ssh のセットアップ(ターミナル起動後に ssh が必要な場合は毎回以下を実施してください)

shell のセットアップ後は、以下で ssh-agent の起動と ssh-add ができます

```
ssh_add
```
