fn main() {
    // scope
    {
        // "hello" はただの文字列リテラルでプログラムにハードコードされる
        // 文字列リテラルは不変なので、String::fromでこれをString形にする
        // String::fromは、String型直下のfrom関数を呼び出している（メソッド呼び出し）
        // String型は、ヒープで管理されるので拡張もできる（拡張はpush_strで行う）
        let mut s = String::from("hello"); // sはここから有効、ここでヒープにメモリを要求する
        s.push_str(", world!");
        println!("{}\n", s);
    } // スコープはここで終わり、sはスコープ内でのみ有効、もう有効ではない
      // Rustは、}でdropと呼ばれる特殊な関数を呼んでヒープからメモリを開放する

    // copyとmove
    {
        // copy
        // スカラ値のようなスタックで管理されるデータは、別の変数に束縛するとcopyされる(スカラ値の集合もcopyされる)
        let x = 5; // 値5をxに束縛する
        let y = x; // xをコピーしてyに束縛する
        print!("x={}, y={}\n", x, y);

        // move
        // Stringのようなヒープで管理されるデータは、別の変数に束縛するとmoveされる
        // shallow copyに似ているが、元の変数は破棄され利用できなくなる（所有者は常に一人）
        let s1 = String::from("hello"); // s1はString(ヒープで管理されるデータ)へのポインタ
        let s2 = s1; // s1のポインタをコピーしてs2に束縛すると、この時点でs1は利用できなくなる
        print!("{}\n", s2);
        // print!("{}\n", s1); // これはコンパイルエラーとなる(s1は利用できない)

        // clone
        // moveではなく、copyをしたい場合は、clone(いわゆるdeap copy)を利用する
        let s3 = s2.clone();
        print!("{} {}\n", s2, s3);

        // MEMO: Copy Trait
        // 型がCopy Traitに適合していればCopyされる
        // 型がDrop Traitを実装している場合は、Copy 注釈をを追加できない
    }

    // copy, moveの概念は関数呼び出しの引数や返り値においても適用される
    {
        let i1 = 5;
        let i2 = makes_copy(i1);
        println!("i1={}, i2={}", i1, i2);

        let s1 = String::from("hello");
        let s2 = takes_and_gives_back(s1);
        println!("s2={}", s2);
        // println!("s1={}, s2={}", s1, s2); // これはコンパイルエラーとなる
    }

    // 参照と借用
    {
        let s1 = String::from("hello");
        // 参照の場合は、String(ヒープで管理されるデータ)へのポインタへのポインタを作成して関数へ渡すので、s1は関数へ渡した後も利用できる
        // 参照の場合は、そのデータの所有権は渡さずに、そのデータへのポインタを渡すことになる
        // 通常の参照はimmutableなので変更することはできない
        let len = calculate_length(&s1);
        println!("The length of '{}' is {}.", s1, len);

        // mutを付けることで、可変な参照を作ることができる
        let mut s2 = String::from("hello");
        change(&mut s2);
        println!("s2={}", s2);

        // 可変な参照は一つしか持つことができない制約がある
        // 以下はOK
        let r1 = &mut s2;
        println!("r1={}", r1); // r1はここまで有効なので問題ない
        let r2 = &mut s2;
        println!("r1={}", r2);

        // 以下はNG
        // let r3 = &mut s2;
        // let r4 = &mut s2; // r3, r4が同時に可変な参照を持つとコンパイルエラーとなる
        // println!("r3={}, r4={}", r3, r4);
    }

    // 文字列スライス
    // スライスは所有権のないデータ型です
    // スライスにより、コレクション全体ではなく、そのうちの一連の要素を参照することができる
    {
        let s = String::from("helloworld");
        let hello = &s[0..5]; // 文字列スライス
        let world = &s[5..10];
        println!("hello={}, world={}", hello, world);

        let s2 = String::from("hello world");
        println!("first_word={}", first_word(&s));
        println!("first_word={}", first_word(&s2));
        println!("first_word={}", first_word2(&s2));

        // 文字列リテラルはスライス
        // 以下のs3の型は&strで、バイナリのその特定の位置を指すスライスで不変な参照である
        let s3 = "hello world";
        // println!("first_word={}", first_word(&s3)); // Error
        println!("first_word={}", first_word2(&s3));
    }
}

// 引数はcopyされて渡され、返り値もcopyされて返される
fn makes_copy(some_integer: i32) -> i32 {
    some_integer
}

// 引数はmoveされて渡され、返り値もmoveされて返される
fn takes_and_gives_back(some_string: String) -> String {
    some_string
}

// 参照を引数として受け取る（これを借用と呼ぶ）
fn calculate_length(s: &String) -> usize {
    // 通常の参照はimmutableなので変更することはできない
    // s.push_str(", world");
    s.len()
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}

// 以下はStringの参照のみ受け取ることができる
fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    return &s[..];
}

// 以下のように書くと、Stringも文字列リテラルも文字列スライスとして受け取ることができる
fn first_word2(s: &str) -> &str {
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    return &s[..];
}
