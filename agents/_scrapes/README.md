# 外部 skill・リポジトリ調査資料

自分用の skill、エージェント設定、文章作成ルールなどを設計・改善するときに参照する外部 skill と関連リポジトリを、`mygit` で取得・コミット固定して管理します。対象はプログラミング分野に限定しません。外部資料は設計・調査のための参照元であり、[`../_skills/`](../_skills/README.md) へ自動インストールしません。

## 構成

```text
_scrapes/
├── _repos/          # 外部Gitリポジトリのローカル参照用キャッシュ（Git管理外）
├── _repo_notes/     # _repos/ のレポジトリ別分析ノート
├── mygit.yaml       # 取得対象と追跡するrevision
├── mygit.lock.yaml  # 取得済みコミットの固定情報
└── .gitignore       # ローカルcloneの除外設定
```

## Index

| パス | 役割 |
| --- | --- |
| [`_repo_notes/`](./_repo_notes/) | `_repos/` 内の外部レポジトリをレポジトリ単位でまとめた分析ノート。詳細はREADMEを参照 |
| [`mygit.yaml`](./mygit.yaml) | `_repos/` に取得する外部Gitリポジトリとrevisionの定義 |
| [`mygit.lock.yaml`](./mygit.lock.yaml) | 取得済み外部Gitリポジトリのコミット固定情報 |
| [`.gitignore`](./.gitignore) | ローカルに置く `_repos/` をGit管理対象外にする設定 |

## 操作方法

このディレクトリで `mygit` を実行します。

```bash
# lock の全リポジトリを取得・復元する
mygit sync

# 全リポジトリの取得元、HEAD、変更有無をローカルで確認する
mygit status

# manifestのrevisionを解決してlockを更新する
mygit update
```

外部 skill を参考にしてローカルの skill を作成・更新する場合は、元リポジトリ全体を `mygit.yaml` と `mygit.lock.yaml` に登録し、lock 済みコミットを `_repos/` に再現します。各リポジトリの調査内容は [`_repo_notes/`](./_repo_notes/) に記録します。

`mygit sync` は `mygit.lock.yaml` のコミットを `_repos/` に再現します。外部リポジトリを更新するときは `mygit.yaml` の `revision` を変更して `mygit update` を実行し、lockfileの差分を確認してから `mygit sync` を実行します。`_repos/` はローカル参照用キャッシュであり、Git管理対象にはしません。
