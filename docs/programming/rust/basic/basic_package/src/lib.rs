// モジュールは、modキーワードで定義できる
// モジュール内に、modキーワードで他のモジュールを入れ子で定義できる
mod front_of_house {
    pub mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}

mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    // enumではヴァリアントにもpubをつけるのは面倒なのでデフォルトで公開される
    pub enum Appetizer {
        Soup,
        Salad,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    // 絶対パスは、クレートの名前かcrateという文字列を使うことでクレートルートからスタート
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    // 相対パスは、self、superまたは今のモジュール内の識別子を使うことで、現在のモジュールからスタートする
    front_of_house::hosting::add_to_waitlist();

    let mut meal = back_of_house::Breakfast::summer("Rye");

    meal.toast = String::from("Wheat");
}
