# Device


## 指標
* Flops
    * Floating-point Operations Per Second
    * 1秒間に何回浮動小数点演算ができるか
    * 倍精度、単精度、ディープラーニングごとでの指標がある
* Tensor
    * 1つの量を表すのがScalar、Scalarが並んだものがVector、Vectorが並んだものがTensor
        * Tensorとは行列のこと
    * ニューラルネットの計算では入力にそれぞれの重みを掛けて合計をとるという計算が主になる
        * 画像などの処理では入力が二次元の配列であることが多い
        * ニューラルネットの各層は多数のニューロンからなっており、ニューロンごとに重みも違うので、重みも2次元の配列となる
        * このため、ニューラルネットの計算では行列と行列の積の計算となる
    * Tensorを入力してその積を計算するためのプロセッサとして、Googleが自社開発してるのがTensor Processing Unitである
    * また、NVIDIAもGoogleに追従して、Tensorコア演算機を搭載している


## TPU
* Tensor Processing Unit
* Googleの自社開発している機械学習やディープラーニングに最適化したプロセッサ
* Cloud TPU
    * GCP上で、TPUシステムをクラウド上でレンタスするサービス
* TPU1.0
    * 2016年5月にGoogle I/Oで発表
    * 92 TFLOPS
* TPU2.0
    * 2017年5月にGoogle I/Oで発表
    * 11.5 PFLOPS
* TPU3.0
    * 2018年5月にGoogle I/Oで発表
    * 100 PFLOPS
    * 空冷では発熱を抑えられないため、液冷システムが導入されている


## NVIDIA TESLA V100
* パフォーマンス
    * NVLink用
        * 倍精度: 7.8 TFLOPS
        * 単精度: 15.7 TFLOPS
        * ディープラーニング: 125 TFLOPS
    * PCIe用
        * 倍精度: 7 TFLOPS
        * 単精度: 14 TFLOPS
        * ディープラーニング: 112 TFLOPS
* NVLink
    * CPUとGPUの接続、GPUとGPUの接続するインターコネクト
    * PCIeで接続するよりも高速にGPU間の通信やメモリアクセスを行える
        * NVLink用の相互接続帯域幅: 300 GB/秒
        * NVLink用の相互接続帯域幅: 32 GB/秒
* NVSwitch
    * 単一サーバ上で16基の完全結合GPUをサポートし、1つのGPUとして使用できる
    * GPU間はNVLinkで接続される
