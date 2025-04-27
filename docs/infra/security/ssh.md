# SSH

## SSHv2

- SSH サーバ接続後の流れ
- 接続後、サーバとクライアントの間で SSH バージョン文字列を交換し，SSHv1 で接続するか，SSHv2 で接続するかを決定する
- その後、使用できる鍵交換方式、希望する公開鍵暗号方式、共通鍵暗号方式、メッセージ認証コード、圧縮アルゴリズムのリストを交換する
- このリストから、使用するアルゴリズムを決定し、Diffie-Hellman 鍵交換方式で暗号化通路に使用する共通鍵を交換する
  - Diffie-Hellman 鍵方式は、交換するカギを直接送ることなく、両者で鍵を共有できるアルゴリズム
- 共通鍵の交換中に、サーバのホスト公開鍵を、クライアントで保持しているホスト公開鍵のデータベースと照合して、ホスト認証もする
  - 新規のホストであれば、データベースに登録するかを尋ねられ、クライアント側で登録を許可する必要がある
  - データベースに登録済みであるホストであれば認証済みとする
  - データベースに登録済みだが、公開鍵が異なっていた場合は不正なホストとみなして接続を停止する
    - サーバを再インストールなどでホスト公開鍵を作り直した場合には、ssh-keygen -R [hostname] などでデータベースからいったんホスト情報を消す必要がある
- 共通鍵を交換し終わったら、暗号化通信路を確立し、以降の通信は暗号化通信路で行われる
- ユーザ認証を以下のどちらかで行う
  - 公開鍵認証
    - 各ユーザは自分の公開鍵・秘密鍵のペアを作っておく
    - 各ユーザは自分の公開鍵をサーバ上になんらかの方法で以下に保存しておく
      - /home/[user]/.ssh/authorized_keys
    - 認証には電子署名を使う
      - ユーザ名、ユーザの公開鍵、ユーザの公開鍵アルゴリズムを記述した認証要求メッセージを作成する
      - この認証要求メッセージに対して、ユーザの秘密鍵を使用して電子署名を作成する
        - 秘密鍵を作成する際にパスフレーズを設定してる場合は、この時にパスフレーズを要求される
      - サーバに認証要求メッセージと電子署名を送信する
        - これを ssh-agent に登録しておくことで、別ホストに ssh するさいにいちいちパスフレーズ入力をする必要がなくなる
        - また、agent 転送することで多段 ssh が楽になる
      - サーバは、認証要求メッセージに含まれるユーザ名、ユーザの公開鍵が、登録済みのユーザ名、公開鍵であることを確認する
      - サーバは、登録されているユーザの公開鍵を使用して、送付された電子署名を審査し、正しいユーザの電子署名であることを確認できると、ユーザ認証成功とする
  - パスワード認証(非推奨)
    - ログインユーザのローカルパスワードによって認証する
    - パスワードは暗号化通信路でやり取りされるので、第三者による観測はできない
    - パスワードが漏洩しなければ問題ないが、パスワードが漏洩した場合にローカルパスワードも漏洩したこととなる
    - このユーザが sudo password を利用していた場合、ssh されるだけでなく、root 権限の操作も可能となってしまう
    - 多段 ssh もできないので不便（やりようによってはできるが、、、
- ユーザ認証が成功したら、ターミナルのセッションが開始される

## ssh-agent

- UNIX domain socket を使って通信する
- eval $(ssh-agent) のように実行すると SSH_AUTH_SOCK、SSH_AGENT_PID の二つの環境変数がセットされる
  - SSH_AUTH_SOCK は、UNIX domain socket のパスがセットされる
  - SSH_AGENT_PID は daemon 化した ssh-agent の pid がセットされる
- ssh は、SSH_AUTH_SOCK が定義されていればそれを使って ssh-agent と通信する
- ForwardAgent が有効な状態で、ssh ログインすると、ログイン先の 環境変数 SSH_AUTH_SOCK がセットされる
  - ログインするたびに新しいパスがセットされるため、既存のログインセッションは間違った SSH_AUTH_SOCK を利用したままになる
  - このため、ログインするたびに $HOME/.ssh/agent に SSH_AUTH_SOCKへの symlink を張るようにして、SSH_AUTH_SOCKを$HOME/.ssh/agent にするとこの問題が回避できる

```
agent="$HOME/.ssh/agent"
if [ -S "$SSH_AUTH_SOCK" ]; then
    case $SSH_AUTH_SOCK in
    /tmp/*/agent.[0-9]*)
        ln -snf "$SSH_AUTH_SOCK" $agent && export SSH_AUTH_SOCK=$agent
    esac
elif [ -S $agent ]; then
    export SSH_AUTH_SOCK=$agent
else
    echo "no ssh-agent"
fi
```

## agent key RSA SHA256:xxx returned incorrect signature type

- RSA SSH key を使用する場合、SHA-1、SHA-256、SHA-512 などのハッシュアルゴリズムで署名可能
- SSH Client が SHA-512 で接続を negotiate したが、[ssh-agent]が SHA-1, SHA-256 で署名を作成した場合に発生する

```
$ ssh -vvv 10.100.100.2
...
debug3: sign_and_send_pubkey: RSA SHA256:xxx
debug3: sign_and_send_pubkey: signing using rsa-sha2-512 SHA256:xxx
agent key RSA SHA256:xxx returned incorrect signature type
...
```

- pagent を利用してる場合は、0.71 以上のバージョンを利用します
  - https://www.chiark.greenend.org.uk/~sgtatham/putty/wishlist/pageant-rsa-sha2.html
- またついでに ed25519 で鍵を作り直しておく
- RLogin を利用してる場合は、オプションのサーバのプロトコルの SSH 認証鍵も変更します
