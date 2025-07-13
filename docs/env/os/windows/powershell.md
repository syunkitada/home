# Powershell

## Hello World

helloworld.ps1
```
echo "Hello World"
```

以下によってスクリプトに実行権限を付与します。

```
> PowerShell -ExecutionPolicy RemoteSigned .\helloworld.ps1
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force .\helloworld.ps1
```

以下によってスクリプトを実行できます。

```
> .\make.ps1
```


## 環境変数

環境変数一覧を表示します。

```
> Get-ChildItem env:
```

環境変数を参照します。

```
echo $env:USERPROFILE
C:\Users\hoge
```

```
echo $env:LOCALAPPDATA
C:\Users\hoge\AppData\Local
```

```
Start-Process -Verb runas
```


notepadをrootで起動する。

```
Start-Process -Verb runas notepad C:\Windows\System32\drivers\etc\hosts
```


powershellをrootで起動する。

```
Start-Process -Verb runas powershell 
```