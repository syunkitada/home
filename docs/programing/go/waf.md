# Go - Web Application Framework

* 世の中的には、gin or echoみたい
    * お互いにベンチマーク載せてライバル視してる感がある


## メモ
* gin
    * https://github.com/gin-gonic/gin
        * License: MIT
    * 古くから存在していて一番メジャーなフレームワーク
    * ベンチマークがいいとこ取りしてる感が漂うけど、良さそう
        * https://github.com/gin-gonic/gin#benchmarks
* echo
    * https://github.com/labstack/echo
        * License: MIT
    * Ginよりも早い?
        * https://github.com/labstack/echo#benchmarks
    * シンプルでなかなか良さそう
    * RESTful APIを作ることに向いている
* revel
    * License: MIT
    * RailsやPlayFrameworkから影響を受けて作られた高機能な大規模向けのWAF
    * Ginやechoで物足りなくなって、パフォーマンスよりも機能を重視視するなら手を出してもいいかも
* その他
    * iris
        * 自称最速フレームワーク
        * 個人開発のようなので利用は避けたほうが良さそう
        * 開発体制が、よくないという噂がある


## 参考
* [GoのWebアプリケーションフレームワーク](https://thinkit.co.jp/article/12144)
* [VoicyがGoLangとEchoを採択した理由。](http://voicetech.hatenablog.com/entry/2017/04/24/195903)
