# Web開発
* https://github.com/syunkitada/web-samples


## 用語メモ
* ECMAScript
    * JavaScript標準化の規格、ES6以降は、
    * 各Editionの概要(6th editionからedition名ではなく年号付きの仕様書名で呼ばれることが推奨される)
        * ES1
            * 1997年、初版
        * ES5、ES5.1
            * 2009年、2011年公開
            * "strictモード"、初期化時に発生しがちなエラーを回避するための追加仕様の追加
            * 多くの曖昧な部分、および仕様に準拠しつつも現実世界の実装の融通の利く振る舞いを明確にした
            * いくらかの新機能、getterやsetter、JSONライブラリのサポート、より完全なオブジェクトの属性のリフレクション
        * ES6(ES2015)
            * 2015年公開
            * クラス、モジュール、イテレータ、for/ofループ、Pythonスタイルのジェネレータ、アロー関数、2進数および8進数の整数リテラル
            * Map、Set、WeakMap、WeakSet、プロキシ、テンプレート文字列、let、const、型付き配列、デフォルト引数、Symbol、Promise、分割代入、可変長引数
        * ES2016
            * 冪乗演算子、Array.prototype.includes
        * ES2017
            * 非同期関数 (async/await)、SharedArrayBufferとAtomics、String.padStart/padEnd、Object.values/entries、Object.getOwnPropertyDescriptors、関数の引数における末尾のカンマ許容
        * ES2018
* JavaScriptライブラリ
    * jQuery
        * ブラウザ互換性があり、便利関数モリモリの古参
        * jQueryに依存したライブラリも多々あり、なんだかんだで使ってしまう
    * Angular
        * 2009年 初版
        * 提供元: Google及びコミュニティ
    * React
        * 2011年 初版
        * 提供元: Facebook及びコミュニティ
    * Vue.js
        * 2014年 初版
        * 提供元: 元GoogleのAngularJS開発チームだったEvan Youさん(中国人)及びコミュニティ
    * どれを使うべきか?
        * jQueryは、一番シンプルでやりたいことを愚直にできる。しかし、コードの規模が大きくなってくると保守性や可読性が落ちてくるため、他のライブラリを選定する人が多い印象
        * AngularとVueでは、VueがAngularのいいとこを取って作られたため、Vueのほうが良さげな印象、最初の学習コストも低く、導入がしやすい
        * Reactは、前提知識、導入コストが多少求められるが、大規模になってきたときの保守性は一番よい
        * 簡単にやるならVueがよく、最初ちょっとしんどいけど将来性みこすならReactかなという印象
* SPA
    * Single Page Application、単一ページで構成されるWebアプリケーション
    * JavaScriptでDOMを操作しページを切り替える
    * AjaxやWebSocketを使用してサーバとデータのやりとりを行う
* Flux、Redux
    * SPAでは、非同期処理、状態管理、レンダリングをうまくコントロールする必要がり、規模が大きくなると複雑になる
    * Fluxは、このような複雑化するアプリの破綻を避け、管理するためのアーキテクチャであり、Facebookが開発しているJavaScriptライブラリである
    * Redux
        * Fluxアーキテクチャを参考に作られたJavaScriptライブラリ
        * 名前の由来は、Reducer + Flux
        * Reactと一緒に使われる（React以外でも一応使える）
        * 本家FluxよりReduxのほうが人気
* トランスパイル
    * ある言語で書いたソースコードを別の言語のそれに変換する機能
    * JavaScriptを生で書くと、様々な記法がありJavaScriptの悪手をする恐れがあり、基本的に別の言語で書いて、JavaScriptに変換して利用することが多い
    * CoffeeScript
        * トランスコンパイル言語
        * 動的型付けで、RubyとPythonにインスパイアされた文法
        * 2015年までは人気だったが、ESへの対応が遅れたことで、今は人気は冷めている
    * TypeScript
        * マイクロソフトによって開発されたトランスコンパイル言語
        * 静的型付けで、JavaやC#にインスパイアされた文法
        * 人気が高い
    * Babel
        * ESを各Editionに変換するトランスコンパイラ
    * SASS
        * CSS用のトランスコンパイル言語
* Node.js
    * V8 JavaScript エンジンで動作する JavaScript 環境
    * サーバ用途としても使えるが、Webフロントエンド開発ツール(タスクランナーやSassやTypeScriptなど)のためによく利用される
    * パッケージマネージャ
        * npm
            * Node.js用のパッケージマネージャ
        * Yarn
            * Facebookが公開したnpmに互換性のあるパッケージマネージャ
            * npmよりもインストールが高速で、バージョン固定もより厳密にできる
            * 後発だけあって、npmも良いらしい
            * TypeScriptやGoogleのスターターキットでもYarnが使われている
                * https://github.com/google/web-starter-kit
                * https://github.com/Microsoft/TypeScript-Vue-Starter#typescript-vue-starter
* タスクランナー
    * 開発時において必要な処理を自動化するためのツール
        * ファイルの変更時に、TypeScriptやSaasなどをコンパイルしたり、Webページを自動リロードしたりする
        * タスクランナー自体は、イベントの監視とタスクの実行を行い、タスク自体はプラグインで拡張する
        * 最近のモジュールバンドラにはタスクランナーのような機能があるため必ずしも必須ではなくなった
    * Grunt
        * 2010年 初版
        * Node.jsの登場と共に現れたタスクランナー
        * 並列処理ができず、重い
    * gulp
        * 2014年 初版
        * 並列処理ができ、Gruntよりも早い
        * Gruntの代わりによく使われている
* モジュールバンドラ
    * CSSや JavaScript、画像などWeb コンテンツを構成するあらゆるファイル(アセット)を「モジュール」という単位で取り扱い、「バンドル」という１つのファイルに最適な形で変換するためのツール
        * モジュールの依存管理なども行う
    * Webpack
        * モジュールバンドラの中堅、他にもparcel, rollup, browserifyなどがあるがトレンドはWebpackが一番使われてそう
        * タスクランナーのような機能もあるのでWebpackだけで完結する場合もあるが、GruntやGulpなどでないと利用できない機能・資産がある場合は併用して使う
* キャッシュ
    * LastModified
    * ETag
* WebP
    * Googleがつくった新しい画像フォーマット
    * jpegやpingより軽く、画像にはWebPを使うのがよい
* SEO
    * 高速性について評価されるようになった
        * キャッシュやWebPを使ってると評価があがる
    * マルチデバイス対応について評価されるようになった
        * PC画面だけでなく、スマートフォンでも見れないと、評価が下がったり、そもそも検索結果にでないようになった
        * URLも統一し、レスポンシブなデザインにする必要がある


* 参考
    * [イマドキのJavaScriptの書き方2018](https://qiita.com/shibukawa/items/19ab5c381bbb2e09d0d9)
    * [Vue.js: 他のフレームワークとの比較](https://jp.vuejs.org/v2/guide/comparison.html)
