# Introduction

## インストール方法

- rustup を使うのが一般的
  - [ドキュメント](https://rust-lang.github.io/rustup/installation/index.html)
- [profile](https://rust-lang.github.io/rustup/concepts/profiles.html)はどれを選択するべきか？
  - CI では、minimal を利用すればよい
  - 開発環境では、default を利用すればよい
    - minimal に加えて、開発用のツールが含まれている

```
# ヘルプ
$ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -h
rustup-init 1.24.3 (c1c769109 2021-05-31)
The installer for rustup

USAGE:
    rustup-init [FLAGS] [OPTIONS]

FLAGS:
    -v, --verbose           Enable verbose output
    -q, --quiet             Disable progress output
    -y                      Disable confirmation prompt.
        --no-modify-path    Don't configure the PATH environment variable
    -h, --help              Prints help information
    -V, --version           Prints version information

OPTIONS:
        --default-host <default-host>              Choose a default host triple
        --default-toolchain <default-toolchain>    Choose a default toolchain to install
        --default-toolchain none                   Do not install any toolchains
        --profile [minimal|default|complete]       Choose a profile
    -c, --component <components>...                Component name to also install
    -t, --target <targets>...                      Target name to also install


# 開発環境ではdefaultを利用してインストールする
$ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile default

# CI環境ではminimalを利用してインストールする
$ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile minimal

$ rustc --version
rustc 1.57.0 (f1edd0429 2021-11-29)

$ cargo --version
cargo 1.57.0 (b2e52d7ca 2021-10-21)
```

- インストールオプションで、--no-modify-path を指定した場合は、.bash_profile に PATH 設定が自動で行われないため、自分で PATH 設定を行います
  - rust のインストール先は、"~/.cargo/bin" です

```
export PATH=$PATH:~/.cargo/bin
```

## プロジェクトの作成と実行

```
$ cargo new hello_cargo --bin
     Created binary (application) `hello_cargo` package

$ ls hello_cargo
Cargo.toml  src/
```

ビルドして、実行ファイルを実行する

```
$ cd hello_cargo
$ cargo build
   Compiling hello_cargo v0.1.0 (/home/owner/programming-rust/basic/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.60s

$ ./target/debug/hello_cargo
Hello, world!
```

ビルドと実行を両方行う(実行ファイルは作成しない)

```
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/hello_cargo`
Hello, world!
```

コンパイルのチェックだけ行う（実行ファイルは作成しない）

```
$ cargo check
```

## Vim の設定

- [rust.vim](https://github.com/rust-lang/rust.vim)
  - syntax チェック、rustfmt による自動フォーマット
- 自動補完はお好みで
