# Webpack
* [公式](https://webpack.js.org/)


## Setup Development Environment
* Basic scripts for initialize

```
cat <<EOS > package.json
{
  "name": "web-samples",
  "version": "1.0.0",
  "main": "index.js",
  "license": "MIT"
}
EOS

yarn add webpack webpack-cli webpack-dev-server style-loader css-loader --dev
mkdir src
mkdir dist

cat <<EOS > webpack.config.js
module.exports = {
  mode: 'development',
  // mode: 'production',

  entry: \`./src/index.js\`,

  // ファイルの出力設定
  output: {
    //  出力ファイルのディレクトリ名
    path: \`\${__dirname}/dist\`,
    // 出力ファイル名
    filename: 'main.js'
  },

  devServer: {
    host: '0.0.0.0',
    port: '9090',
    contentBase: 'dist',
  },
};
EOS
```

* Start development server with following command
    * This server build src files automaticaly, when these are changed
    * Builded files store in memory of this server, and reload blowser automaticaly

```
npx webpack-dev-server
```


* If you want to build, run following command.

```
npx webpack
```
