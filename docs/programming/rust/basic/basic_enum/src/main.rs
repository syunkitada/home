#[derive(Debug)]
enum UsState {
    Alaska,
    // ...
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn value_in_cents(coin: Coin) -> u32 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}

fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

fn main() {
    let penny = Coin::Penny;
    let nickel = Coin::Nickel;
    let dime = Coin::Dime;
    let quarter = Coin::Quarter(UsState::Alaska);
    println!(
        "hello: {}, {}, {}, {}",
        value_in_cents(penny),
        value_in_cents(nickel),
        value_in_cents(dime),
        value_in_cents(quarter)
    );

    // Rustにはnullがなく、代わりにOption enumを利用する
    // enum Option<T> {
    //     Some(T),
    //     None,
    // }
    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
    println!("hello: {:?} {:?}", six, none);

    // matchは包括的で、すべての可能性を網羅しないとコンパイラエラーとなるが、これは"_"プレースホルダーで回避できる
    // 0u8は、有効な値として0から255までを取るが、有効な可能性をすべて列挙する代わりに"_"で列挙されてない可能性すべてに対する処理を記述できる
    let some_u8_value = 0u8;
    match some_u8_value {
        1 => println!("one"),
        3 => println!("three"),
        5 => println!("five"),
        7 => println!("seven"),
        _ => (), // () はただのユニット値なので、_の場合は何も起こらない（この処理を記述しないとコンパイルエラーとなる）
    }

    // 一つのパターンだけにマッチすればよいコード
    let some_u8_value = Some(0u8);
    match some_u8_value {
        Some(3) => println!("three"),
        _ => (),
    }

    // 一つのパターンだけにマッチすればよければ、以下のようにif letで書くこともできる
    if let Some(3) = some_u8_value {
        println!("three")
    }
}
