# Python Tools

## Index

| Link | Description |
| --- | --- |
| [.python-version](.python-version) | Pythonのバージョン指定です。 |
| [pyproject.toml](pyproject.toml) | Pythonプロジェクトの定義です。 |
| [uv.lock](uv.lock) | uvの依存関係ロックファイルです。 |

## セットアップ方法

- makeを実行すると、内部の[scripts/setup_common.sh](../../../scripts/setup_common.sh)によってpython_toolsがインストールされ使えるようになります。
- PATHの設定は、[home/.envrc](../../.envrc) で管理されており、`${HOME}/home/python_tools/.venv/bin`が利用できます。
