# Comment

## コメントを書く場所とポイント

- 「誰が」「いつ」読むのか？を考えると、「どんな情報を」書けばいいかがわかる
- コードの(コードで表現できない)説明を書く場所
  - コードコメント
    - 誰が: 将来そのコードをメンテする人（自分を含む）
    - いつ: 次にそのコードを修正するとき実装から挙動を読み取るとき
    - どんな情報を: 「あえてそうしている」こと
      - 書かれなかったこと（意図や理由、捨てた実装等）はコードには残らない
      - 「あえてそうしている」ことの例
        - メジャーなライブラリがあるのに自前で実装している
        - ユースケースが特殊で、適切なオプションが提供されていなかった
  - コミットメッセージ
    - 誰が: レビュアー、将来そのコードをメンテする人（自分を含む）
    - いつ: プルリクエストのレビューをするときにステップごとに見る、今のコードになった時期や理由を探るとき
    - どんな情報を: コードの変更の目的、理由
  - プルリクエスト（説明欄、コメント）
    - 誰が: レビュアー
    - いつ: コードレビュー時
    - どんな情報を
      - プルリクエストの背景説明
        - 「AAをした際にBBする機能を追加」
        - 「AAのの情景化でBBというバグが発生したので」
      - 実装全体の説明、相談事項
        - 「ここ実装めっちゃ悩んだ（悩んでる）」
        - 実装の時に参考にしたドキュメント等
    - コメントする上での心構え
      - コメントに対して誠実であること
        - レスバトル、論破合戦のようなことはせず、誠実に対話をする
        - コメントしてくれたらお礼を言う、コメント通りに修正してくれたらお礼を言う
        - たまに感情的なコメントをする人がいるが、こちらも感情的になってはならない
      - 自分の意見と相手の意見が対立したとき
        - 自分の意見が間違ってることもあるし、相手の意見が間違ってることもあるということを自覚する
          - 自分の意見が正しいと思いこまないこと、相手の意見が正しいと思い込まないこと
          - 自分のほうが経験値があるから、相手のほうが経験値があるから、といって正しいことを言ってるとは限らない
        - 合意形成を取る
          - 自分の意見を整理し正しく伝える、相手の意見を整理し正しく聞く
            - 自分が背景を誤解をしてることもあれば、相手が背景を誤解していることもある
            - 自分の意図が相手に伝わってないこともあれば、相手の意図を自分が正しく把握していないこともある
            - 自分の説明が下手だったり、相手の説明が下手だったりすることもある
            - たどたどしくても、誠実に伝える努力、聞く努力をしましょう
          - お互いの目的をすり合わせる
            - そもそもの目的や背景の認識があってない可能性がある
          - 目的のための実現手段をすり合わせる
            - なぜそのような実装や修正をするのかの理由を正しく理解する