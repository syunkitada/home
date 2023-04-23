# 環境用のドキュメント

- zsh, tmux, (neo)vim などの環境に関するドキュメントです
- zsh or fish ?
  - 結論
    - zsh を採用
  - fish は補完機能やハイライトなど、デフォルトでとても優れて機能を持っている
  - 一方で以下の欠点を持っているため、導入は断念しました
    - bash と非互換な構文（具体的な違いは以下を参考にしてください）
      - https://github.com/fish-shell/fish-shell/wiki/Shell-Translation-Dictionary
      - コマンド実行後のステータスは、$? は使えず、代わりに $status を使う
    - bash 前提のキーバインドが正しく動作しない（これは個人的な理由ではある）
      - なぜか意図しない文字入力が入ってしまう（ハイライトのせいかも？）
      - 自分の場合、基本は zsh を利用するが、場合によって(zsh がない環境で) bash も利用するため、bash と同等のキーバインド設定が使えないと困る