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


