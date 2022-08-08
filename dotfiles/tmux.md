# tmux

# command

- t -- tmux を起動
- tt -- IS_TMUXT=true で tmux を起動(prefix が、^t(autohotkey: \<!u)になる)

## tmux

- tmux の key table は、 3 種類ある
  - prefix
    - bind [key] [action...] で設定し、[prefix key]を押した後に、[key] を押すことで、[action]が実行される
    - 例: bind h select-pane -L
  - root
    - bind -n(-T root) [key] [action...] で設定し、[key]を押すと、[action]が実行される
    - 例: bind -n C-t new-window
  - copy-mode, copy-mode-vi
    - bind -T copy-mode [key] [action...] で設定する
- 独自の key table
  - bind -T [table] [key] [action..] で独自の key table でバインドを定義することができる
  - テーブル切り替えは、set key-table [table] で行う
- 参考
  - [Tmux in practice: local and nested remote tmux sessions](https://www.freecodecamp.org/news/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795/)
  - [Binding Keys in tmux](https://www.seanh.cc/2020/12/28/binding-keys-in-tmux/)
