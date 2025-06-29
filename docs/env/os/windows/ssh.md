# SSH

## Enable SSH Agent Service

管理者権限でPowerShellを起動する

```
> Start-Process -Verb runas powershell
```

SSHエージェントサービスを有効にします。

```
> Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service -PassThru | Select-Object -Property Name, StartType, Status
```
