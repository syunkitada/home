fn main() {
    println!("Hello, world!");

    another_function(5);

    let x = another_function2(10);
    println!("HOGE {}", x)
}

fn another_function(x: i32) {
    println!("Another function: {}", x);
}

// 文と式
// 文: 値を返さもの
// 式: 値を返すもの

fn another_function2(x: i32) -> i32 {
    return x + 1;
}
