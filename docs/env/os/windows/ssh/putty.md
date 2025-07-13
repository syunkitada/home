## Use PuTTY PAGENT

PuTTY の PAGENT を利用する場合の手順を説明します。

OpenSSH Agent が利用できない場合や、PuTTY を利用したい場合は、以下の手順で PAGENT をセットアップします。

VSCode や RLogin などを利用する場合は、OpenSSH を利用できるので、この方法は必要ありません。

### PuTTYry をセットアップする

- [PuTTYrv (PuTTY-ranvis)](https://www.ranvis.com/putty) から 64bit.7z をダウンロードしてデスクトップに展開します。
- puttygen.exe
  - PuTTY の SSH キーを生成するためのツールです。
  - 既存の OpenSSH の秘密鍵を PuTTY 形式に変換することもできます。
- pagent.exe
  - PuTTY の SSH エージェントです。
  - puttygen.exe で生成した秘密鍵を読み込んで利用します。
  - 以下のようにショートカットを作成しておき、タスクバーにピン留めしておくと便利です。
  - `C:\[Path...]\PuTTY-ranvis\pageant.exe C:\[Path...]\[Key Name].ppk`
