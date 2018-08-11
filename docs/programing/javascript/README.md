# JavaScript


## Memo
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
* ライブラリ
    * jQuery
        * ブラウザ互換性があり、便利関数モリモリの古参
        * jQueryに依存したライブラリも多々あり、なんだかんだで使ってしまう
    * Angular
    * Vue.js
    * React


* 参考
    * [イマドキのJavaScriptの書き方2018](https://qiita.com/shibukawa/items/19ab5c381bbb2e09d0d9)
    * [Vue.js: 他のフレームワークとの比較](https://jp.vuejs.org/v2/guide/comparison.html)
