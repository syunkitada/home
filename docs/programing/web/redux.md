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
