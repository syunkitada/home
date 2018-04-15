# 電話網


## 歴史
* 交換手の時代
    * 電話と電話の間に「交換手」と呼ばれる人がいて、その交換手が配線を切り替えて電話とつなげていた
    * ダイヤルがなく、受話器を上げると交換手に繋がり、「だれだれにつなげてください」と告げると交換手がつなげてくれる
* 自動交換機の時代
    * 1926年から徐々に「交換手」に代わる「ステップ・バイ・ステップ方式の自動交換機」が導入された
        * 電話機にダイヤルが付いており、ダイヤル番号に応じて、その数字の回線に次々に接続していき、最終的に相手の電話機に回線がつながるという仕組み
        * 次々に接続していくという動作からステップ・バイ・ステップという名称になった
        * 1952には、ステップ・バイ・ステップ交換機で市内通話は自動的につながるようになった
            * しかし、市外通話は各地の自動交換機を経由するためには交換手が必要で時間がかり、また運用コストが高いというデメリットがあった
    * 1955年に「クロスバ交換機」が導入された
        * 縦と横に張り巡らされた複数のバーがクロス(交差)して設置され、電話をかけると、ダイヤルされた電話番号の情報から各バーに付いている電磁石の磁力により縦と横のバーが接触し、相手に電話をつなぐ
        * 市外通話も全自動化され、市外通話料金の自動記録も可能になった
        * 1967年には県庁所在地級の都市で利用されるようになり、1978年には全国に広まった
    * 1982年には音声や制御信号をすべてデジタル化した「デジタル交換機」が導入された
    * 2004年には「IP電話」サービスである「ひかり電話」が開始した
        * IP電話はインターネット網を利用し、電話は「SIPサーバ」で管理される


## IP電話
* SIP(Session Initiation Protocol)
    * 音声や動画のセッションを接続・切断する制御プロトコル
    * 音声伝送などの機能は含まないため、他のプロトコルと組み合わせて利用することで、電話としての機能を実現する
    * HTTPをベースとしている
* ENUM(tElephone NUmber Mapping)
    * DNSを用いて、業者の枠を超えたすべての電話番号とドメイン名を関連付ける
    * 電話番号がENUMに対応している必要がある
    * ENUMの動作(一般固定電話からIP電話につなげる場合)
        * 一般固定電話から電話をかけると、公衆電話網を介し、ゲートウェイに制御が渡される
        * ゲートウェイは、ENUMのDNSリゾルバに電話番号を渡し、SIPサーバとIP電話のURI(URL)を得る
        * ゲートウェイは、一般のDNSリゾルバにSIPサーバのURLを問い合わせ、SIPサーバのIPアドレスを得る
        * ゲートウェイはSIPサーバにアクセスし、SIPサーバはIP電話のURIをもとにDNSサーバへアクセスしてIP電話のIPアドレスを得る
        * SIPサーバがIP電話に対して呼制御を行う