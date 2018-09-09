# Redux
* https://redux.js.org/introduction/coreconcepts
* https://redux.js.org/basics


## 概要
* Storeという一つのStoreを管理するためのモデルを持つ
    * これは、setterを持たないただのモデル(read-only)
    * Stateの変更はActionでのみ行うことができ、何のActionでStateが変更されたか明確にされる
* 何らかの要因でイベントが発行されると、ActionsでActionを発行
* Actionを処理し、Reducer関数に受け渡す
* Reducer関数はStateとActionを結びつけるためもの
    * 現在のStateと実行されたActionを引数に取り、Actionによって更新された次のStateを返す
* StateをViewに渡して適切に更新する


## Setup Development Environment
* require [react](react.md)

```
yarn add redux react-redux
```



## 非同期処理を行うためのライブラリ
* 非同期処理をどこに書くのか、どのように書くのか、そしてどこから呼び出すべき

## redux-thunk
* アクションではなく関数を返すアクションクリエータを作成できる
* アクションのディスパッチを遅らせるために、または特定の条件が満たされた場合にディスパッチするために使用できる


## redux-saga
* https://redux-saga.js.org/
* アプリケーションの副作用（例えば、データフェッチのような非同期タスク、およびブラウザキャッシュへのアクセスなどの不純なプロシージャ）の実行を管理し効率的にすることを目的とするライブラリ
* ジェネレータと呼ばれるES6機能を使用するため、シンプルなテストが可能で、フローを同期コードとして読みやすくします
* redux-thunkでは、イベントが発生するたびにアクションがディスパッチされる可能性があり、多重実行されないような書き方が必要
* redux-sagaは、一つ一つの処理が無限ループで定義されており、イベントが発火するまで待ち、イベント発火で処理が進行して処理され、またイベント発火まで待つ
* タスクという概念をReduxに持ち込む
* 非同期処理をタスクのような独立した実行単位で管理できる
* できること
    * select: Stateから必要なデータを取り出す
    * put: Actionをdispatchする
    * take: Actionを待つ、イベントの発生を待つ
    * call: Promiseの完了を待つ
    * fork: 別のタスクを開始する
    * join: 別のタスクの終了を待つ


## redux-observable
* redux-observableは、redux-thunkに触発されたreduxのミドルウェアです。
* Observable、Promise、iterableのいずれかのアクションを返す関数をディスパッチすることができます。
* オブザーバブルがアクションを発行したとき、または約束がアクションを解決したとき、またはイテラブルがアクションを出すとき、そのアクションはいつものようにディスパッチされます。
* RxJSと一緒に使う


# Development Purposes / debug
* redux-devtools
    * Redux DevTools is a set of tools for your Redux development workflow.
* redux-logger
    * redux-logger logs all actions that are being dispatched to the store.
