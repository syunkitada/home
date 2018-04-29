# メモ


## includeディレクトリ
* ヘッダファイルはすべてincludeディレクトリに含まれ、必要に応じてincludeされ利用される
* linuxのソースなどでも同じように管理されている


## 関数バリア
* ヘッダファイルが複数includeされるのをふせぐ

```
# exec-all.h
 20 #ifndef EXEC_ALL_H
 21 #define EXEC_ALL_H
...
 80 #endif
```


## typedef
* 新しい型を定義するキーワード(予約語)
* typedef 既存の型名 新規の型名
    * 変数宣言をするふりをして、頭にtypedefをつけると型になる

### 利用方法: ポインタの作成を容易にする
* intを指すポインタを宣言するには、int *p; もしくは int* p; を記述する。

```
typedef int *PINT;   // 「intを指すポインタ」型として PINT を宣言
PINT p1, p2;         // 「intを指すポインタ」のp1 と p2 を作成できる
```


## ##演算子
* ##前処理演算子を使い、マクロ展開時に二つの字句を一つに結合することができる

```
 413 #define DEFINE_I440FX_MACHINE(suffix, name, compatfn, optionfn) \
 414     static void pc_init_##suffix(MachineState *machine) \
 415     { \
 416         void (*compat)(MachineState *m) = (compatfn); \
 417         if (compat) { \
 418             compat(machine); \
 419         } \
 420         pc_init1(machine, TYPE_I440FX_PCI_HOST_BRIDGE, \
 421                  TYPE_I440FX_PCI_DEVICE); \
 422     } \
 423     DEFINE_PC_MACHINE(suffix, name, pc_init_##suffix, optionfn)
 424
 425 static void pc_i440fx_machine_options(MachineClass *m)
 426 {
 427     m->family = "pc_piix";
 428     m->desc = "Standard PC (i440FX + PIIX, 1996)";
 429     m->default_machine_opts = "firmware=bios-256k.bin";
 430     m->default_display = "std";
 431 }
 432
 433 static void pc_i440fx_2_11_machine_options(MachineClass *m)
 434 {
 435     pc_i440fx_machine_options(m);
 436     m->alias = "pc";
 437     m->is_default = 1;
 438 }
```


## TAILQ
* Cのマクロで書かれた双方向リンクリストの実装
* glibcに含まれてる
* http://koseki.hatenablog.com/entry/20120105/tailq
