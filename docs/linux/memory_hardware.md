# ハードウェアから見たメモリ

## 規格
* [DDR4](https://ja.wikipedia.org/wiki/DDR4_SDRAM)


## 物理メモリ
L1キャッシュでのアクセスミスは数10クロックのペナルティが生じる
L2キャッシュでのアクセスミスは数10バスクロックのペナルティが生じる

キャッシュに読み込まれるタイミング
* アプリケーションが参照したメモリの内容がキャッシュにない場合
* アプリケーションがメモリに書き込みを行った内容がキャッシュにない場合
* アプリケーションがプリフェッチ命令を実行した場合
* ハードウェア・プリフェッチャーが動作した場合
読み込み書き込みの最小単位はキャッシュライン（64バイト）

| バンド幅 | |
| ストライド幅 | チャンクサイズ／ブロックサイズ(4KB) |
| ストライプ幅 | データディスク数×ストライド |
| レイテンシ | |


## 用語
* SPD
    * Serial Presence Detect
    * PCやサーバーを起動するさいに、メモリモジュールの情報をBIOSに伝える規格/仕組み
    * SPDデータ(メモリモジュールの情報)
        * メーカ名、規格、容量、搭載DRAM(CHIP)の情報(メーカー名・規格・bit構成・容量)、動作クロック周波数、CAS Latnecy(Column Address Strobe Latency)、動作電圧、ECC(誤り訂正符号)などのが含まれる
    * SPDデータはEEPROM(Electrically Erasable Programmable Read Only Memory)と呼ばれるモジュールに保存される
        * ライトプロテクトの機能が搭載されている
        * データの書き換えには専用の機器が必要
    * 参考: [メモリモジュールに"SPD"という情報があるのを知っていますか?](http://pc.watch.impress.co.jp/docs/column/century_micro/1076466.html)


## 記事
* 2017/09/29 (サーバー/ハイエンドPCの主記憶を変革するNVDIMM技術](http://pc.watch.impress.co.jp/docs/column/semicon/1083346.html)
* 2011/11/18 [次世代DRAM規格「DDR4」と新技術規格「3DS」の概要を公表- Server Memory Forum 2011](http://www.kumikomi.net/archives/2011/11/rp49serv.php?page=2)
