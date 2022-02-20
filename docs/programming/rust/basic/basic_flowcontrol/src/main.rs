fn main() {
    let number = 3;

    if number < 5 {
        println!("true");
    } else {
        println!("false");
    }

    let a = [10, 20, 30, 40, 50];
    let mut index = 0;
    let until = a.len() - 1;

    loop {
        if index == until {
            break;
        }

        index = index + 1;
        if index == 3 {
            continue;
        }

        println!("loop element = {}", a[index]);
    }

    let mut index = 0;
    while index < 5 {
        println!("while element = {}", a[index]);
        index = index + 1;
    }

    for e in a.iter() {
        println!("for element = {}", e)
    }
}
