# Device

## 指標

- Flops
  - Floating-point Operations Per Second
  - 1 秒間に何回浮動小数点演算ができるか
  - 倍精度、単精度、ディープラーニングごとでの指標がある
- Tensor
  - 1 つの量を表すのが Scalar、Scalar が並んだものが Vector、Vector が並んだものが Tensor
    - Tensor とは行列のこと
  - ニューラルネットの計算では入力にそれぞれの重みを掛けて合計をとるという計算が主になる
    - 画像などの処理では入力が二次元の配列であることが多い
    - ニューラルネットの各層は多数のニューロンからなっており、ニューロンごとに重みも違うので、重みも 2 次元の配列となる
    - このため、ニューラルネットの計算では行列と行列の積の計算となる
  - Tensor を入力してその積を計算するためのプロセッサとして、Google が自社開発してるのが Tensor Processing Unit である
  - また、NVIDIA も Google に追従して、Tensor コア演算機を搭載している

## TPU

- Tensor Processing Unit
- Google の自社開発している機械学習やディープラーニングに最適化したプロセッサ
- Cloud TPU
  - GCP 上で、TPU システムをクラウド上でレンタスするサービス
- TPU1.0
  - 2016 年 5 月に Google I/O で発表
  - 92 TFLOPS
- TPU2.0
  - 2017 年 5 月に Google I/O で発表
  - 11.5 PFLOPS
- TPU3.0
  - 2018 年 5 月に Google I/O で発表
  - 100 PFLOPS
  - 空冷では発熱を抑えられないため、液冷システムが導入されている

## NVIDIA TESLA V100

- パフォーマンス
  - NVLink 用
    - 倍精度: 7.8 TFLOPS
    - 単精度: 15.7 TFLOPS
    - ディープラーニング: 125 TFLOPS
  - PCIe 用
    - 倍精度: 7 TFLOPS
    - 単精度: 14 TFLOPS
    - ディープラーニング: 112 TFLOPS
- NVLink
  - CPU と GPU の接続、GPU と GPU の接続するインターコネクト
  - PCIe で接続するよりも高速に GPU 間の通信やメモリアクセスを行える
    - NVLink 用の相互接続帯域幅: 300 GB/秒
    - NVLink 用の相互接続帯域幅: 32 GB/秒
- NVSwitch
  - 単一サーバ上で 16 基の完全結合 GPU をサポートし、1 つの GPU として使用できる
  - GPU 間は NVLink で接続される
