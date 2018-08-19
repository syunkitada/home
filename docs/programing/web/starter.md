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


## Initializing Git repository

```
git init

cat << EOS > .gitignore
# See https://help.github.com/ignore-files/ for more about ignoring files.

# dependencies
/node_modules

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOS
```
