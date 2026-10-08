#!/usr/bin/env bash

set -Eeuo pipefail

# Stop hook の入力を読み捨てる。通知本文には会話内容を含めない。
cat >/dev/null

project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
project_name="$(basename -- "${project_root}")"

if command -v myntfy >/dev/null 2>&1; then
    myntfy send \
        --title "Codex 完了" \
        --tags tada \
        "${project_name} のタスクが完了しました。" \
        >/dev/null 2>&1 || true
fi

# Stop hook は、exit 0 の場合に JSON を返す必要がある。
printf '{}\n'
