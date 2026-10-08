# Codex hooks

Codex のライフサイクル hook スクリプトを配置します。[`../../setup.sh`](../../setup.sh) の `codex` は、このディレクトリ直下の `*.sh` を `CODEX_HOME/hooks/` へシンボリックリンクします。

`Stop` hook は Codex のターン終了時に実行されます。Codex の意味的な成功・失敗を判定するイベントではないため、中断や通常終了を含めて通知されます。また、Codex の `/hooks` 画面で初回の hook trust review が必要です。

## Index

| パス | 役割 |
| --- | --- |
| [`notify_myntfy.sh`](./notify_myntfy.sh) | Codex の `Stop` hook から、タスク完了を `myntfy` で通知 |
