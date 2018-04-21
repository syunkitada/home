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
