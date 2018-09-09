# React
* [公式](https://reactjs.org/)
* [公式: Tutorial](https://reactjs.org/tutorial/tutorial.html)
* [公式: Main Concepts]https://reactjs.org/docs/hello-world.html


## Setup Development Environment
* Install common package

```
sudo yarn global add create-react-app
```

* Create new project

```
create-react-app my-app
cd my-app

rm -f src/*
```

* Start development server
    * This server build src files automaticaly, when these are changed
    * Builded files store in memory of this server, and reload blowser automaticaly

```
yarn start
```

* https://github.com/facebook/react-devtools
* https://github.com/pangloss/vim-javascript
* react-router
    * [basic-components](https://reacttraining.com/react-router/web/guides/basic-components)
    * [basic-example](https://reacttraining.com/react-router/web/example/basic)



## 型チェック
* TypeScript
    * コンパイル時に型チェックが行われる、トランスコンパイル言語
* Flow、
    * Facebookが作成した、JavaScript の構文を拡張して静的型解析機能を提供する
    * トランスコンパイル言語ではないので、拡張された構文だけを取り除くツールが必要だが、自動化ツールを使えばよい
* prop-typesを利用して型チェックする方法
    * https://reactjs.org/docs/typechecking-with-proptypes.html
    * コンポーネントにpropTypesプロパティをセットすることで、動的に型チェックを行える
    * パフォーマンスの理由から開発モードでのみ動作する
