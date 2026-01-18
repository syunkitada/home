# OpenCode

https://opencode.ai/docs/

## OpenCode Zen

https://opencode.ai/workspace

1. Google アカウントでログイン
2. ログインするとAPI Keyが発行されるので、コピーする

## セットアップ

```
$ npm i -g opencode-ai@latest

$ opencode auth login

┌  Add credential
│
◇  Select provider
│  OpenCode Zen
│
●  Create an api key at https://opencode.ai/auth
│
◇  Enter your API key
│  ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
│
└  Done
```

## 料金

https://opencode.ai/docs/zen/#pricing

無料で使えるものを選択して利用する。

```
# model一覧
$ opencode models
opencode/grok-code

# oneshot
$ opencode --model opencode/grok-code run "Explain how closures work in JavaScript"
```