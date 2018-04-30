# Google App Engine


## チュートリアル
* https://cloud.google.com/appengine/docs/standard/go/quickstart?hl=ja
* https://cloud.google.com/appengine/docs/standard/go/building-app/?hl=ja


## .zshrc
```
export PATH=$PATH:/usr/local/go/bin
export GOPATH=${HOME}/go

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/owner/google-cloud-sdk/path.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/owner/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/owner/google-cloud-sdk/completion.zsh.inc'; fi
```


## Go Runtime Environment
* https://cloud.google.com/appengine/docs/standard/go/runtime

* Goのアプリケーションコードは、セキュアサンドボックス環境(コンテナ?)でビルドされ実行される
* GAEはGo http packageに似たインターフェイスを提供し、GAE appsはスタンドアローンのGo web serverに似ている

* デプロイの流れ(憶測、Kubernetesっぽい)
    * File upload done.
        * Google Cloud Storageにファイルをアップロード
    * Updating service [default]...done.
        * アップロードされたファイルをセキュアサンドボックス環境(コンテナ?)でビルドし、実行する
    * Setting traffic split for service [default]...done.
        * サービスVIPのトラフィックを新しいバージョンに切り替える
    * Deployed service
        * 完了

```
$ gloud app deploy
gcloud is correct? [Yes, No, Abort, Edit]:y
Services to deploy:

descriptor:      [/home/hoge/go/src/go-app/app.yaml]
source:          [/home/hoge/go/src/go-app]
target project:  [helloworld-111111]
target service:  [default]
target version:  [20180430t183500]
target url:      [https://helloworld-111111.appspot.com]


Do you want to continue (Y/n)?  y

Beginning deployment of service [default]...
╔════════════════════════════════════════════════════════════╗
╠═ Uploading 23 files to Google Cloud Storage               ═╣
╚════════════════════════════════════════════════════════════╝
File upload done.
Updating service [default]...done.
Setting traffic split for service [default]...done.
Deployed service [default] to [https://helloworld-111111.appspot.com]
```
