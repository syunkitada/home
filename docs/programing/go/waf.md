# Go - Web Application Framework

* 現状、デファクトスタンダードなフレームワークはない
* 世の中的には、gin or echoが人気みたいだが、どのプロジェクトも運営人数が少なく、開発体制としては不安
    * net/httpだけでもある程度は作り込めるので、フレームワークは使わないという選択肢もありだと思う
    * とりあえず、フルスタックなフレームワークにどっぷり浸かるのはやめたほうがいい


## 方針
* WAFの機能を、ルータ、ハンドラ、モデルに分けて考える
* ルータ
    * 標準のnet/httpだけでもなんとかなるので、必ずしもフレームワークを使う必要はない
    * フレームワークを利用する場合は、net/httpのhttp.Handlerインターフェイスに準拠しているもののみを利用する
        * プロジェクトがなくなっても、最悪乗り換えられるようにする
        * 現状だと、ginがよさそう?(プロジェクトメンバが複数いて、パフォーマンスもそこそこなので)
* ハンドラ
    * net/httpのhttp.Handlerに準拠して書く
    * テンプレートエンジン
        * 標準で十分事足りる?
* モデル
    * RAW or ORM
        * 速度を優先するならRAW、速度を少し犠牲にして便利さを選ぶならORM
    * RAW
        * 公式でサポートしているのでこれを使う
            * https://golang.org/pkg/database/sql/
    * ORM
        * gormがメジャー
        * genmai
        * xorm
    * マイグレーションツール
        * https://qiita.com/nownabe/items/1acce9f6b9f14f74c965
* セキュリティ
    * 参考
        * [Quick security wins in Golang (Part 1)](https://blog.rapid7.com/2016/07/13/quick-security-wins-in-golang/)


## ルータメモ
* gin
    * https://github.com/gin-gonic/gin
        * License: MIT
        * メンバー数: 3人
    * 古くから存在していて一番メジャーなフレームワーク
    * ベンチマークがいいとこ取りしてる感が漂うけど、良さそう
        * https://github.com/gin-gonic/gin#benchmarks
    * droneや、gorushで使われており、プロジェクト構成もこの辺参考にするとよい？
* chi
    * https://github.com/go-chi/chi
        * License: MIT
        * メンバー数: 1人
    * net/httpに準拠
    * Production環境で(社内かもしれないが)実績がある
        * Pressly, CloudFlare, Heroku, 99Designs, Origamiなど
    * ベンチマークも標準のnet/httpばりに性能出る
    * ドキュメントが少ないのがネック
    * 今後に期待
* echo
    * https://github.com/labstack/echo
        * License: MIT
        * メンバー数: 1人
    * Ginよりも早い?
        * https://github.com/labstack/echo#benchmarks
    * シンプルでなかなか良さそう
    * ベンチマークも標準のnet/httpばりに性能出る
* revel
    * https://github.com/revel/revel
        * License: MIT
        * メンバー数: 2人
    * RailsやPlayFrameworkから影響を受けて作られた高機能な大規模向けのWAF
    * Ginやechoで物足りなくなって、パフォーマンスよりも機能を重視視するなら手を出してもいいかも
* その他
    * iris
        * 自称最速フレームワーク
        * 開発者のマナーがよくないという噂がある?


## 参考
* [GoのWebアプリケーションフレームワーク](https://thinkit.co.jp/article/12144)
* [VoicyがGoLangとEchoを採択した理由。](http://voicetech.hatenablog.com/entry/2017/04/24/195903)
