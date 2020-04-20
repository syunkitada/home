# vppinfra

## vppinfra/clib.h

```
  110 /* Hints to compiler about hot/cold code. */
  111 #define PREDICT_FALSE(x) __builtin_expect((x),0)
  112 #define PREDICT_TRUE(x) __builtin_expect((x),1)
```

- \_\_builtin_expect
  - コンパイラに分岐予測の最適化のためのヒントを提供する
  - 第一引数が、第二引数の結果になる場合に、分岐予測が成功しやすくなる
