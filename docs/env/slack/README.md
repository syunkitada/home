# Slack

[KEYBIND] key=^<Click>; tags=slack; action=スレッドなどを新しいウィンドウで開きます;
[KEYBIND] key=^k; tags=slack; action=DM、チャネルの検索バーへ移動し、検索結果へ移動できます;
[KEYBIND] key=^g; tags=slack; action=検索バーへ移動し、検索結果へ移動できます;
[KEYBIND] key=^f; tags=slack; action=チャネル内のメッセージの検索バーへ移動し、検索結果へ移動できます;

## VIP通知について

特定人物からの通知を見逃さないようにするために、その人をVIPとして設定して、VIP用に通知設定を行うことができます。

これにより、普段は通知しないように設定しつつも、上長などの偉い人からの通知は常に許可するといったことができます。

[連絡先を VIP として追加する](https://slack.com/intl/ja-jp/help/articles/34963579361683-%E9%80%A3%E7%B5%A1%E5%85%88%E3%82%92-VIP-%E3%81%A8%E3%81%97%E3%81%A6%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B)

## 検索機能

[Slack 内で検索する](https://slack.com/intl/ja-jp/help/articles/202528808-Slack-%E5%86%85%E3%81%A7%E6%A4%9C%E7%B4%A2%E3%81%99%E3%82%8B)

モディファイアの例

- in: #[channel name] : チャネル内のメッセージに絞り込む
- in: @[user] : あるユーザとのDM内のメッセージに絞り込む
- from:@[user] : あるユーザからのメッセージに絞り込む
- to:@[user] : あるユーザへのメッセージに絞り込む
- with:@[user] : あるユーザが参加しているスレッド、あるユーザとのDMのメッセージに絞り込む
- is:thread : スレッド内のメッセージに絞り込む
- is:bookmark : ブックマーク内のメッセージに絞り込む
- before, after, on
- before:[日時] : 特定日時より前のメッセージに絞り込む
- after:[日時] : 特定日時より後のメッセージに絞り込む
- on:[日時] : 特定日時のメッセージのみに絞り込む

組み合わせの例

- 今日の自分が参加してるスレッドのメッセージから検索する（is:threadは付けなくてもよい）
  - on:Today with:me [keyword]
- 今日の自分のメッセージから検索する
  - on:Today from:me [keyword]
