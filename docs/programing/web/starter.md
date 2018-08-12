# Starter


## Usage Links
* [yarn](https://yarnpkg.com/en/docs/usage)


## Init Scripts
* node、yarnのインストール
```
wget https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.xz
sudo mkdir -p /usr/local/node
sudo tar -C /usr/local/node --strip-components 1 -xf node-v8.11.3-linux-x64.tar.xz
rm -rf node-v8.11.3-linux-x64.tar.xz
sudo ln -s /usr/local/node/bin/node /usr/local/bin/node
sudo ln -s /usr/local/node/bin/npm /usr/local/bin/npm
sudo ln -s /usr/local/node/bin/npx /usr/local/bin/npx
sudo npm install -g yarn
```


## Start Project
```
git init
echo node_modules >> .gitignore

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


## 手動ビルド
```
npx webpack
```

## 開発サーバ
* ファイル変更時に自動ビルド、ブラウザの自動リロードを行う
* ビルド結果はメモリ上に保存されるだけ
```
npx webpack-dev-server
```
