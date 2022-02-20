struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

// #[derive(Debug)] を構造体前に定義すると、printlnで{:?}と指定することで、デバック出力ができるようになる
// これはトレイトと呼ばれ、構造体に有用な振る舞いを追加することができる
#[derive(Debug)]
struct User2 {
    username: String,
    email: String,
}

#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

// メソッド
// メソッドはimplブロックによって宣言する
impl Rectangle {
    // selfで自身を参照することができる
    // &selfとすると、不変で借用する
    // &mut selfとすれと、可変で借用する
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

// implブロックは複数存在できる
impl Rectangle {
    // selfを引数に取らない関数の事を関連関数と呼ばれる
    // これは :: によって呼ぶことができる(String::from(..)のように）
    fn square(size: u32) -> Rectangle {
        Rectangle {
            width: size,
            height: size,
        }
    }
}

// 異なる型を生成する名前付きフィールドのないタプル構造体
// フィールドに紐づけられた名前がなく、フィールドの方だけのタプル構造体と呼ばれる
struct Color(i32, i32, i32);

fn main() {
    println!("Hello, world!");
    let user1 = build_user1(String::from("hoge"), String::from("piyo"));
    output_user(user1);

    let user2 = build_user2(String::from("hoge2"), String::from("piyo2"));
    output_user(user2);

    // 他のインスタンスからインスタンスを生成する
    let user3 = build_user2(String::from("hoge3"), String::from("piyo2"));
    let user4 = User {
        email: String::from("hoge4"),
        ..user3
    };
    output_user(user4);

    let user5 = User2 {
        username: String::from("user5"),
        email: String::from("email5"),
    };
    println!(
        "debug: debug={:?} username={} email={}",
        user5, user5.username, user5.email
    );

    let black = Color(0, 0, 0);
    println!("black=R={},G={},B={}", black.0, black.1, black.2);

    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };
    println!(
        "The area of the rectangle is {} square pikels.",
        rect1.area(),
    );

    println!("Can rect1 hold rect2? {}", rect1.can_hold(&rect2));
    println!("Can rect1 hold rect3? {}", rect1.can_hold(&rect3));

    let rect4 = Rectangle::square(4);
    println!("rect4: width={}, height={}", rect4.width, rect4.height);
}

fn build_user1(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
        sign_in_count: 1,
    }
}

// build_user1の省略記法
fn build_user2(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}

fn output_user(user: User) {
    println!(
        "hello {} {} {} {}",
        user.username, user.email, user.sign_in_count, user.active
    );
}
