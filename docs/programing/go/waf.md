# Go - Web Application Framework

- 現状、デファクトスタンダードなフレームワークはない
- 世の中的には、gin or echo が人気みたいだが、どのプロジェクトも運営人数が少なく、開発体制としては不安
  - net/http だけでもある程度は作り込めるので、フレームワークは使わないという選択肢もありだと思う
  - とりあえず、フルスタックなフレームワークにどっぷり浸かるのはやめたほうがいい

## 方針

- WAF の機能を、ルータ、ハンドラ、モデルに分けて考える
- ルータ
  - 標準の net/http だけでもなんとかなるので、必ずしもフレームワークを使う必要はない
  - フレームワークを利用する場合は、net/http の http.Handler インターフェイスに準拠しているもののみを利用する
    - プロジェクトがなくなっても、最悪乗り換えられるようにする
    - 現状だと、gin がよさそう?(プロジェクトメンバが複数いて、パフォーマンスもそこそこなので)
- ハンドラ
  - net/http の http.Handler に準拠して書く
  - テンプレートエンジン
    - 標準で十分事足りる?
- モデル
  - RAW or ORM
    - 速度を優先するなら RAW、速度を少し犠牲にして便利さを選ぶなら ORM
  - RAW
    - 公式でサポートしているのでこれを使う
      - https://golang.org/pkg/database/sql/
  - ORM
    - gorm がメジャー
    - genmai
    - xorm
  - マイグレーションツール
    - https://qiita.com/nownabe/items/1acce9f6b9f14f74c965
- セキュリティ
  - 参考
    - [Quick security wins in Golang (Part 1)](https://blog.rapid7.com/2016/07/13/quick-security-wins-in-golang/)

## ルータメモ

- gin
  - https://github.com/gin-gonic/gin
    - License: MIT
    - メンバー数: 3 人
  - 古くから存在していて一番メジャーなフレームワーク
  - ベンチマークがいいとこ取りしてる感が漂うけど、良さそう
    - https://github.com/gin-gonic/gin#benchmarks
  - drone や、gorush で使われており、プロジェクト構成もこの辺参考にするとよい？
- chi
  - https://github.com/go-chi/chi
    - License: MIT
    - メンバー数: 1 人
  - net/http に準拠
  - Production 環境で(社内かもしれないが)実績がある
    - Pressly, CloudFlare, Heroku, 99Designs, Origami など
  - ベンチマークも標準の net/http ばりに性能出る
  - ドキュメントが少ないのがネック
  - 今後に期待
- echo
  - https://github.com/labstack/echo
    - License: MIT
    - メンバー数: 1 人
  - Gin よりも早い?
    - https://github.com/labstack/echo#benchmarks
  - シンプルでなかなか良さそう
  - ベンチマークも標準の net/http ばりに性能出る
- revel
  - https://github.com/revel/revel
    - License: MIT
    - メンバー数: 2 人
  - Rails や PlayFramework から影響を受けて作られた高機能な大規模向けの WAF
  - Gin や echo で物足りなくなって、パフォーマンスよりも機能を重視視するなら手を出してもいいかも
- その他
  - iris
    - 自称最速フレームワーク
    - 開発者のマナーがよくないという噂がある?

## 参考

- [Go の Web アプリケーションフレームワーク](https://thinkit.co.jp/article/12144)
- [Voicy が GoLang と Echo を採択した理由。](http://voicetech.hatenablog.com/entry/2017/04/24/195903)
