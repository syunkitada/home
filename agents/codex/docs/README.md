# Codex

## Index

| パス | 役割 |
| --- | --- |
| [`config.md`](./config.md) | Codexの`sandbox_mode`と`approval_policy`の整理。 |

## 1. ChatGPT Plus のアカウントを作成する

Codexを利用するにはPlus以上のアカウントを作成します。

1. ChatGPTの無料アカウントを作成し、ChatGPTにログインします。（Googleのアカウント連携ですぐに利用開始できます）
2. ChatGPTにログインすると、右上に無料オファーのリンクがあります。（2026/09/20現在）
3. 支払い方法を指定してサブスクリプションを登録します。無料オファーの場合は初月無料です。

## 2. ChatGPTのデバイスコード認証を有効化する。（リモートサーバでCodexを利用するために必要です）

以下のページを開き、デバイスコード認証を有効にします。

https://chatgpt.com/settings/security

## 3. Codexをインストールする

```
npm install -g @openai/codex
```

```
$ codex --version
codex-cli 0.155.1
```

## 4. Codexでログインする

codexを起動すると、

```
$ codex
```

認証方式を聞かれるので、"Sign in with Device Code" を選択します。

```
$ codex
2. Sign in with Device Code
     Sign in from another device with a one-time code
```

URLを開いて、そのページにone-timeコードを入力します。

```
Welcome to Codex, OpenAI's command-line coding agent

  Finish signing in via your browser

  1. Open this link in your browser and sign in

  https://auth.openai.com/codex/device

  2. Enter this one-time code after you are signed in (expires in 15 minutes)

  XXXX-YYYY

  Continue only if you started this login in Codex. If a website or another person gave you this code, cancel.

  Press esc to cancel
```

成功すると以下のようなメッセージが出てきて完了です。

```
Welcome to Codex, OpenAI's command-line coding agent

✓ Signed in with your ChatGPT account

  Before you start:

  Decide how much autonomy you want to grant Codex
  For more details see the Codex docs

  Codex can make mistakes
  Review the code it writes and commands it runs

  Powered by your ChatGPT account
  Uses your plan's rate limits and training data preferences

  Press enter to continue
```