# iptables


http://qiita.com/suin/items/5c4e21fa284497782f71



conntrack entry のみかた
* 最新のカーネルだとprocfs自体から消えている

iptables (ip masquarede)


NAT: IPアドレスの変換をする
DNAT: Destination IP Nat
SNAT: Source IP Nat

IP Masquerade: UDP/TCPのポート番号の変換まで行う


## netfilterとは
カーネルのパケット処理をhookしてユーザランドで制御できるようにしたもの
ユーザ側で操作、参照しやすい形態

iptablesが有名だがコンポーネントの一つ

conntrack, ulogd, ip6tables, arptables, ebtables等
netfilterプロジェクトの一つがiptablesなだけで、支援バッチも多数存在

## conntrack
* connection trackingの略ですべての通信がリアルタイムに記録される
* TCPの通信が終了した場合でも、設定されたタイムアウトまで蓄積される
* タイムアウトするとconntrack tableから破棄される
* src dst IPとPortのtupleをhash化してhash tableで処理している
* conntrack tableの確認
  * conntrack tableは多い時で10万近いリストになることもある
  * cat /proc/net/nf_conntrack でも見れるが古いやり方(最新のカーネルだと、procfs自体から消えてる
  * conntrack-toolsを使う
  * $ yum install conntrack-tools, $ apt-get install conntrack
  * $ conntrack -L
  * [ASSURED]は破棄されず、[UNREPLIED]はtimeoutか上限数に達すると破棄される

[ASSURED] + SYN_SENTが増える(SYN_ACKが返ってこない)
HALF-ASSUREDが増える([ASSURED][UNREPLIED]に遷移しない])
-> コネクション要求に失敗してる
SYN_SENTまで通る場合は、その先のロードバランサやリアルサーバの問題の可能性が多い
HALF-ASSUREDが増加する場合は、コネクションオープンまたは、クローズの要求に応答が戻ってこない状態
NW的に疎通不可能か、レスポンスが極端に低下している


[ASSURED] + ESTABLISHEDが増える（終了しない通信が増える)
-> コネクションは確立しているがレスポンスがない

CLOSEが増加する場合
コネクションは確立したけど、レスポンスがないため開きっぱなしのコネクションが増加
リアルサーバからレスポンスがなく通信がFINへ遷移しないコネクションが増加している状態
逆SYN flood状態



Bufferbloat
* 不適切なネットワークキューイングや過剰なバッファによりレイテンシーが悪化、または不安定な状態
* レイテンシーの悪化、揺らぎにより、TCPの服装制御の混乱を招き、スループットの低下も起こる

LinuxのNetwork Scheduler デフォルトはFIFO
ab ->  IP Stack ->  queue queue queue ->  NIC Buffer
db ->               | -- Buffer Size -- |

Nicのバッファサイズが大きいとロスが増加

遅いもの、大きいものは処理に時間がかかる
早いもの、小さいものはその逆 VoIPとかDNSとか


アクティブキューイング
FIFOを廃止し、キューイングを様々な方法で制御

CoDel(Controlled Delay)
RTTやプロトコル等を考慮して必要に応じてキューの先頭に割り込む


TCP small queues
Byte Queue Limits




## iptables


iptables [-t テーブル] コマンド [マッチ] [ターゲット/ジャンプ]


テーブルとチェイン
それぞれのテーブルの中で、どのタイミングでフィルタリングするかを決めるのがチェイン

filterテーブル  INPUT、OUTPUT、FORWARD
natテーブル POSTROUTING、PREROUTING、OUTPUT
mangleテーブル  POSTROUTING、PREROUTING、INPUT、OUTPUT、FORWARD
Rawテーブル PREROUTING、OUTPUT

INPUT   入力（受信）に対するチェイン
OUTPUT  出力（送信）に対するチェイン
FORWARD フォアード（転送）に対するチェイン
PREROUTING  受信時に宛先アドレスを変換するチェイン。タイミングとしてはfilterで適用されるルールより手前
POSTROUTING 送信時に送信元アドレスを変換するチェイン。これもfilterの後でパケットが送信される直前


パケットフロー
http://inai.de/images/nf-packet-flow.png



## コマンド
-A（--append）  指定チェインに1つ以上の新しいルールを追加
-D（--delete）  指定チェインから1つ以上のルールを削除
-P（--policy）  指定チェインのポリシーを指定したターゲットに設定
-N（--new-chain）   新しいユーザー定義チェインを作成
-X（--delete-chain）    指定ユーザー定義チェインを削除
-I（--insert）  指定したチェーンにルール番号を指定してルールを挿入する。（ルール番号を省略した際にはルール番号は1に設定され、チェーンの先頭に挿入される。）


## パラメータ
-s (--source)   パケットの送信元を指定。特定のIP（192.168.0.1）や範囲（192.168.0.0/24）を指定する
-d (--destination)  パケットの宛先を指定。指定方法は-sと同じ。
-p (--protocol) チェックされるパケットのプロトコル。 指定できるプロトコルは、 tcp、udp、icmp、allのいずれか1つか、数値。
-i (--in-interface) パケットを受信することになるインターフェース名。eth0、eth1など
-o (--out-interface)    送信先インターフェース名を指定
-j (--jump) ターゲット（ACCEPT、DROP、REJECT）を指定



-j で指定するターゲット一覧
ターゲットの一覧

指定方法    内容
ACCEPT  パケットの通過を許可
DROP    パケットを破棄。応答を返さない。
REJECT  パケットを拒否し、ICMPメッセージを返信
REDIRECT    特定ポートにリダイレクト
LOG マッチしたパケットのログを記録



# nat
sudo iptables -t nat -A POSTROUTING -p TCP -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE --to-ports 1024-65535
sudo iptables -t nat -A POSTROUTING -p UDP -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE --to-ports 1024-65535
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 ! -d 172.16.100.0/24 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 -d 255.255.255.255 -j RETURN
sudo iptables -t nat -A POSTROUTING -s 172.16.100.0/24 -d base-address.mcast.net/24 -j RETURN


