# zsh

## 補完について

- いくつかのプラグインが存在するが、コンフリクトしやすいので注意
- 便利そうではあるけどいったん保留
- zsh-autosuggestions
  - history などから候補を一つ表示してくれる
  - fish だと標準である機能ではある
  - # source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
  - # export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
- zsh-autocomplete
  - https://github.com/marlonrichert/zsh-autocomplete
  - 補完候補を tab 押さなくても表示してくれるやつ
  - auto-fu.zsh よりも多機能
- auto-fu.zsh
  - https://github.com/hchbaw/auto-fu.zsh.git
  - 補完候補を tab 押さなくても表示してくれるやつ
  - 更新は止まってる

## zsh vs fish

- 結論、zsh のが良いと思います。
- fish は補完機能やハイライトなど、デフォルトでとても優れて機能を持っています。
- 一方で以下の欠点を持っています。
  - bash と非互換な構文であること（具体的な違いは以下を参考にしてください）
    - https://github.com/fish-shell/fish-shell/wiki/Shell-Translation-Dictionary
    - コマンド実行後のステータスは、$? は使えず、代わりに $status を使う
  - bash 前提のキーバインドが正しく動作しないこと（これは個人的な理由ではある）
    - なぜか意図しない文字入力が入ってしまう（ハイライトのせいかも？）
- 環境によってはbashしか使えない場合もあるので、bashとの互換性の強いzshに慣れ親しんだ方が総合的に良いと思います。
