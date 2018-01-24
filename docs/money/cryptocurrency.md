# 仮想通貨

## 目次
| Link | Description |
| --- | --- |
| [Bitcoinの仕組み](#Bitcoinの仕組み)       | Bitcoinの仕組み    |
| [仮想通貨の考察](#仮想通貨の考察)         | 適当に考察してみた |
| [Etheriumの掘り方](#mining_etherium.md)   | Etheriumの掘り方   |
| [Monaの掘り方](#mining_mona.md)           | Monaの掘り方       |


## Bitcoinの仕組み
* 大本は論文
    * Bitcoin: A Peer-to-Peer Electronic Cash System
    * Satoshi Nakamoto（中本 哲史）（2008）
* Bitcoinとは厳密には仮想通貨ではなく、通貨取引システム
    * その中でやる取りされる仮想通貨の単位を1Bitcoinと呼んでいる
* BitcoinはOSS
    * OSSなので中での取引や、通貨の管理の仕方がすべてオープンになってる
* 中央管理者はおらず、ネットワークに参加しているノード達によって元帳(取引履歴)が管理される
* ユーザは自分のアドレス(口座)を用意するが、これは誰かに申請するのではなく、勝手に作成してよい
    * ユーザは秘密鍵と公開鍵のペアを作り、この公開鍵がアドレスとなる
    * これは全世界でユニークであり何個持ってもいい
* 自分のアドレスから、他人のアドレスに送金したい場合、
    * 自分の秘密鍵を使って、送金リクエストをネットワーク上に流すことができる
    * ネットワーク上には送金リクエストのプールがあり、そこにいったん保存される
    * この時、送金リクエストに手数料を付けてもいいし、付けなくてもよい
* 元帳への書き込み
    * 暗号バトルに勝者したものが元帳への書き込みの権利を得る
        * 暗号バトルとはお題が出て、参加ノードはハッシュを生成して、それをひたすらお題に当てはめて正解を探している
            * 参加ノードが多ければ、このバトルに勝つのは難しいし、また、ACICなどを導入した強い参加者がいると、当然これも勝つのは難しい
            * このお題の難易度も参加者の人数によって変わり、参加者が多ければ難しくなる
        * 誰かが正解すると、それを他のノードが本当に正解かを投票し、51%以上が認めると、元帳への書き込みの権利を得る
        * もし、勝者が二人以上出てしまったら
            * タイミングによっては勝者が二人以上出ることがある
            * すると、ネットワークが分裂し(これをフォークする)、それぞれのネットワークでトランザクションが進む
            * しかし、何トランザクションか進むと、差分が出てくるので、その時元帳が長いほうが正しい元帳と判断され、そうでない場合は破棄される
    * リクエストはプールから拾われて一定量束てて、元帳に書き込む
        * この単位がトランザクション
    * 一定量しか束ねられないので、手数料が高いものが優先的に拾われる
    * 一定時間放置されたリクエストもトランザクションに一定量含ませなければならないので、手数料がなくても一定時間たてば処理される
* 新規発行コイン
    * 新規発行コインは、元帳へ書き込んだノードに対して、報酬として支払われる
    * しかし、無限に新規発行コインを作ると、価値が暴落してしまうので、一定年ごとに新規発行コインを減らしている
    * 2015年 25BTC支払われているものが、2017年には12.5BTCに半減、そして2021年にはそれが6.25BTCになる
    * 報酬が下げているは、ビットコインの流通量を減らして、年を増すごとに「採掘インセンティブ重視」から「送金手数料（トランザクション・フィー）インセンティブ重視」の、より純粋な決済ネットワークへとシフトしていくためである
* ブロックチェーンと仮想通貨の元帳
    * ブロックチェーンとはP2Pで元帳を分散管理する技術
    * 元帳のページがブロックで、元帳がブロックチェーン
* ノードの採算について
    * ノードの報酬は、元帳へ書き込む際の新規発行コインと、送金手数料である
    * 他の参加者ノードに勝てないとこの収入を得られるチャンスが減る
    * 電気代や機器の維持費と比較して採算が取れるなら良し、そうでないなら参加すべきではない
        * 参加者が多かったり、ASICなどを導入してマイニングされてるようなコインは採算がとりずらくなっている
        * 国や地域によって電気代が安い高いがあるので、その条件によって有利不利もある
    * とはいえ、採算がとれなくなってしまうとコイン自体が破綻してしまうので、採算の取れるように、参加ノードが減ったり、手数料が上げられたりでどこかに落ち着くはず
* 現金化について
    * コインを現金や物品と取引する業者がいる
        * このため、コインに金銭的な価値が生まれて取引が成り立っている
    * 取引は取引所でアカウントとアドレスを作成することでできる
        * またこのアドレスで通貨を掘ることでお金を稼げる
        * 公開鍵(アドレス)と秘密鍵は取引所で管理されている
            * たまにニュースであるが、ここがハッキングされて秘密鍵を盗まれるとコインも送金されて盗まれる
    * 取引所
        * bitflyer
            * 大手
            * メジャーコインを扱うならここ
        * conincheck
            * 中堅
            * マイナーコインもある
        * zaif
            * 中堅


## 仮想通貨の考察
* 現状についての整理(at 2018/01/05)
    * 2017年末に仮想通貨全体が高騰し、そして一時急落したが再度復活し、現在はゆるやかに上がっている
        * 価格が落ちるときは皆一緒に暴落するが、人気のある通貨はすぐ復活した、そうでないとここで沈んでいく
    * 仮想通貨の値段が上がる理由は、売りの数よりも買いの数(人や資金)が増えたから
        * 現状は、ギャンブル化していて、まだ上がると考えて買いに走っている人が多いが、どこかで飽和し、崩壊する
        * また、2017年末は買いをあおるような記事が多く出ている印象で、ギャンブルテーブルへの新規の参加者も増えたと思われる
    * バブルが崩壊するのはいつ頃か?
        * ギャンブルテーブルにつぎ込まれてる資金というのは、参加者が出し合ってるに等しい
        * バブルが崩壊するのは、新規の参加者が減って、投入資金も減ってくるころ合い（予想できないが、数カ月で起きると予想？)
            * いまの熱がちょっと冷めて来たころ合いにことが起こる
        * ギャンブルテーブルに資金の投入量が減ってくれば、皆うすうす気づいてテーブルからお金を回収しだす
        * バブルが崩壊は、このたくさんの人がギャンブルから降り始めたとき、乗り遅れるとお金を回収できずにババを引かされることになる
    * バブルが崩壊しない可能性
        * 熱が冷めきっても、仮想通貨の価格がどこかで安定するという可能性も少しある
        * bitcoinなどは店先で一応使えるので、その価格が0になるとは考えられない
            * 反対に、どこかの店がbitcoinの取り扱いを止めると言ったらその価格は0になるだろう
* 勝ち残るコインは?
    * PoW, PoS, PoIは個人がだれでも参加できて、中央集権がなくなり管理されるのがいいところだが、現在の仮想通貨はどれもお金儲けのギャンブルの場として使われてる
        * また、ねずみ講のような初期参加者に有利な仕組みであり、将来にわたって受け入れられるものではない
            * 今は参加者がいるが、どこかのタイミングでみなが気づきなりたたなくなる
            * 初期参加者がタイミングを合わせて売りにでも走ったら、暴落するのは一瞬だろう
    * 結局残るのは大手金融が参加しているPoC
        * Ripleなどはもうしばらく伸びると思われる
        * しかし、投機目的ではなく送金目的の本来の目的で利用されるはずで、ある程度のところで落ち着くはず
    * これから、一攫千金狙うなら
        * 参加者が多くなってしまった既存のコインで勝負するのはそろそろ危ない
            * 危ないといわれ続けて、やはり上がってくるから何とも言えないが、リスクも高まってると思う
        * 新規のPoCが出て来たらチャンスかも？