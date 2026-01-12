# OpenCode

https://opencode.ai/docs/

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

https://opencode.ai/docs/zen/#pricing

```
# model一覧
$ opencode models
opencode/grok-code

# oneshot
$ opencode --model opencode/grok-code run "Explain how closures work in JavaScript"
```