# DHCP
* Dynamic Host Configuration Protocol
* ネットワーク接続するのに必要な情報を自動的に割り当てるアプリケーション層プロトコル
* UDPを使う
* DHCPはもともとBOOTP(BOOTstrap Protocol)がもとになっており、メッセージ構造などはほぼそのまま
    * BOOTPは単にクライアントにIPアドレスを通知するだけだったのに対して、DHCPでは拡張部分を利用して、リース期間を設定したり、デフォルトゲートウェイの設定などもできる


## 目次
| Link | Description |
| --- | --- |
| [DHCPメッセージ](#DHCPメッセージ)             | |
| [初回リース時のフロー](#初回リース時のフロー) | |
| [リース延長時のフロー](#リース延長時のフロー) | |
| [DHCP Relay](#DHCP Relay)                     | |
| [DHCPの冗長化](#DHCPの冗長化)                 | |
| [参考](#参考)                                 | |


## DHCPメッセージ
* DHCPでは、DHCPメッセージをUDPでやり取りする
* ポート番号は、サーバ側が67、クライアント側が68
* メッセージのオプション部分に、タグ番号で示される様々な種類のデータを設定できる
| タグ値（10進）|  タグ名          | サイズ（オクテット）|  意味                                                                                 |
| 1             |  Subnet Mask     | 4                   |  サブネット・マスク・アドレス                                                         |
| 3             |  Router          | 可変                |  デフォルト・ゲートウェイ・アドレス                                                   |
| 6             |  Domain Server   | 可変                |  DNSサーバ・アドレス                                                                  |
| 12            |  Hostname        | 可変                |  クライアントのホスト名                                                               |
| 15            |  Domain Name     | 可変                |  DNSドメイン名                                                                        |
| 50            |  Address Request | 4                   |  クライアントがリクエストするIPアドレス                                               |
| 51            |  Address Time    | 4                   |  IPアドレス・リース期間                                                               |
| 53            |  DHCP Msg Type   | 1                   |  DHCPメッセージ・タイプ                                                               |
| 54            |  DHCP Server Id  | 4                   |  DHCPサーバ・アドレス                                                                 |
| 56            |  DHCP Message    | 可変                |  DHCPエラーメッセージ                                                                 |
| 58            |  Renewal Time    | 4                   |  クライアントがアドレスを取得してからRenewal（リースの再延長要求）するまでの期間（秒）|
| 59            |  Rebinding Time  | 4                   |  クライアントがアドレスを取得してからRebindingするまでの期間（秒）                    |
* タグ「53」のDHCP Msg Typeで、クライアント・サーバ間でメッセージ要求の意味を解釈している
| 値 | メッセージ名   | 意味                                                                                    |
| 1  | DHCPDISCOVER   | クライアントがサーバを「発見」するためのメッセージ                                      |
| 2  | DHCPOFFER      | サーバからクライアントへの設定値「候補」を通知するメッセージ                            |
| 3  | DHCPREQUEST    | クライアントが決定したサーバへの取得依頼メッセージ                                      |
| 4  | DHCPDECLINE    | クライアントからサーバへの拒否（エラー）メッセージ                                      |
| 5  | DHCPACK        | サーバからクライアントへの取得正常終了メッセージ                                        |
| 6  | DHCPNAK        | サーバからクライアントへの取得拒否（エラー）メッセージ                                  |
| 7  | DHCPRELEASE    | クライアントからサーバへのリリース要求メッセージ                                        |
| 8  | DHCPINFORM     | IPアドレス取得は行わず、オプション取得のみ行う場合にクライアントから送られるメッセージ  |
| 9  | DHCPFORCERENEW | サーバからクライアントへの再構成要求                                                    |


## 初回リース時のフロー
* DHCPクライアント: DHCP DISCOVERをブロードキャストで送信する
* DHCPサーバ: DHCP DISCOVERを受け取ったら、クライアントに対してDHCP OFFER(提案IPを添えたレスポンス)を返す
* DHCPクライアント: 一番最初に受け取ったDHCP OFFERで提案されたIPを払い出してもらえるように、DHCP REQUESTをブロードキャストで送信する
* DHCPサーバ: サーバは要求に対して、IPの払い出しを承認する DHCP PACKを返す
    * もしダメであれば、DHCP PNAKを返す
* DHCPクライアント: PACKを受信したらIPアドレスなどの設定を行う
    * PNAKの場合は、DHCP DISCOVERからやり直しとなる


## リース延長時のフロー
* DHCP PNAKで、クライアントにはAddress Time(リース期間)のほかに、Renewal Time、Rebinding Timeが通知される
* Renewal Timeを過ぎるとクライアントは、IPの払い出したサーバにユニキャストでDHCP REQUESTを送信して、IPの延長(Renew)を行う
    * 一般的にRenewal Timeは、Address Timeの半分で設定される
    * Renewは成功するまで定期的に繰り返される
* Renewが失敗し続け、Rebinding Timeを過ぎるとクライアントは、DHCP DISCOVERをブロードキャストで送信して、IPの再取得(Rebind)を行う
    * 一般的にRebinding Timeは、Address Timeの75%で設定される


## DHCP Relay
* DHCPを使うには同セグにDHCPサーバを設置する必要があるが、あるセグから他セグのDHCPサーバへDHCPメッセージを仲介する「DHCP Relay」という仕組みがある
* DHCP Relayはルータがサポートしている場合が多い


## DHCPの冗長化
* pacemakerなどでアクティブ・スタンバイの構成にする
* kubernetesなどのオートヒールが可能なオーケストレーションツールを利用する
* 設定すべきmacアドレス、IPアドレスが分かってれば、DBなどで管理して、まったく同じ払い出しをするDHCPサーバをどうセグに複数台立てる


## 参考
* http://www.atmarkit.co.jp/ait/articles/0202/26/news001.html
