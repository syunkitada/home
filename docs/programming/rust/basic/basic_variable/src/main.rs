fn main() {
    //// 変数と可変性
    // デフォルトで変数は不変なので、再代入しようとするとコンパイルエラーとなる
    // let x = 5;  // imutable
    // x = 6;

    // 変数を可変にするには、mutキーワードを付ける
    let mut x = 5; // mutable
    println!("The value of x is: {}", x);

    x = 6;
    println!("The value of x is: {}", x);

    //// シャドーイング
    // 変数を再定義した場合、1番目の変数は２番目の変数によって覆い隠されます（これをシャドーイングと言います）
    let y = 5;
    println!("The value of y is: {}", y);
    let y = y + 1;
    println!("The value of y is: {}", y);
    let y = "y";
    println!("The value of y is: {}", y);

    //// データ型（スカラ値）
    // Rustは静的型付き言語だが、Goと同様にコンパイル時に変数の型を自動判定してくれるので明示的に定義する必要はない

    // 以下のように型に複数の可能性のある場合は型注釈を付ける必要がある
    let guess: u32 = "43".parse().expect("Not a number!");
    println!("The value of y is: {}", guess);

    /*
    8-bit	i8	u8
    16-bit	i16	u16
    32-bit	i32	u32
    64-bit	i64	u64
    arch	isize	usize
    */

    let x = 2.0; // f64

    let y: f32 = 3.0; // f32

    let t = true;
    let f: bool = false;

    // char型
    let c = 'z';

    // 文字列リテラル(Stringではない)
    // バイナリファイルに直接ハードコードされる
    let str = "hoge";

    let tup: (i32, f64, u8) = (500, 6.4, 1);
    let tup = (500, 6.4, 1);
    let (x, y, z) = tup;
    println!("The value of y is: {}, {}", y, tup.1);

    let a = [1, 2, 3, 4, 5];
    let mounths = ["January", "February", "March"];
    println!("The value of y is: {}", a[1]);
}
