# ハードウェアから見たメモリ


## 規格
* [DDR4](https://ja.wikipedia.org/wiki/DDR4_SDRAM)


## モジュール
* SPD
    * Serial Presence Detect
    * PCやサーバーを起動するさいに、メモリモジュールの情報をBIOSに伝える規格/仕組み
    * SPDデータ(メモリモジュールの情報)
        * メーカ名、規格、容量、搭載DRAM(CHIP)の情報(メーカー名・規格・bit構成・容量)、動作クロック周波数、CAS Latnecy(Column Address Strobe Latency)、動作電圧、ECC(誤り訂正符号)などのが含まれる
    * SPDデータはEEPROM(Electrically Erasable Programmable Read Only Memory)と呼ばれるモジュールに保存される
        * ライトプロテクトの機能が搭載されている
        * データの書き換えには専用の機器が必要

