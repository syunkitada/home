# Firebase

- モバイルアプリや Web アプリを開発するためのプラットフォーム
- 静的ファイルのホスティング、認証、メッセージ(画像も含む)、プッシュ通知、解析機能などを提供している
- これだけで、簡易的なアプリケーションが作れてしまう
- 認証機能だけでもさくっと使えてしまうのでとても便利
  - App Engine などでも認証機能使いたい場合は、Firebase を使うのが楽そう
- 料金は、Spark Plan (デフォルト)であれば無料で使える
  - https://firebase.google.com/pricing
  - App Engine に紐づけて Firebase のプロジェクトを作ろうとすると Blaze Plan が選択されるので注意
- とりあえず、チュートリアルをやるとよくわかる
  - https://codelabs.developers.google.com/codelabs/firebase-web/

## チュートリアル メモ

- CLI からログインのテストをする場合、リモートの場合は--no-localhost オプションを付ける必要がある

```
$ firebase login --no-localhost
Visit this URL on any device to log in:
https://accounts.google.com/o/oauth2/auth?client_id=....

? Paste authorization code here: ....

✔  Success! Logged in as xxxxx@gmail.com
```

- web-start を起動する場合は、--project の指定が必要
- また、リモートでのテストの場合は、0.0.0.0 でリッスンするように-o オプションが必要

```
$ firebase serve --project friendlychat-xxxx -o 0.0.0.0
```

- リモートで(特定のドメインで)行うと、ブラウザコンソールに以下のようなエラーが出るので、ドメインを Firebase から許可する必要がある

```
This domain (xxxx) is not authorized to run this operation. Add it to the OAuth redirect domains list in the Firebase console -> Auth section -> Sign in method tab.
```

- セキュリティルールはしっかり設定すること
