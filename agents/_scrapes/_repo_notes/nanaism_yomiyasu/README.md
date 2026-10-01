# nanaism/yomiyasu 調査ノート

> このファイルは、外部リポジトリのローカルスナップショットを対象にした中間調査資料です。内容は調査時点のファイルとGit履歴に基づくため、上流の更新後も自動では追随しません。

## 対象・調査時点

| 項目 | 内容 |
| --- | --- |
| 対象 | [`nanaism_yomiyasu`](../../_repos/nanaism_yomiyasu/) |
| 上流として確認できた取得元 | `https://github.com/nanaism/yomiyasu.git`（ローカルcloneの`origin`） |
| 調査日 | 2026-10-01 |
| HEAD | `b14ee43c9b722cf4fd2bb1e893c6c386f1a362aa` |
| HEADの直近コミット | 2026-10-01、`docs: READMEのインストール手順に最新版へのアップデート方法（npx skills update）を追記` |
| タグとの関係 | `git describe --tags --always --dirty` は `v1.0.1-1-gb14ee43`。プラグインマニフェストのバージョンは`1.0.1` |
| 取得時の状態 | ソースcloneのワーキングツリーはclean |

直近の履歴では、初期リリース後に意味保持、比喩表現の含み、`壊れる`の技術的な具体化、慣用句の扱いが調整され、今回のHEADではREADMEに`npx skills update yomiyasu`が追加された。

## 目的と全体像

`yomiyasu（よみやす）`は、AIが生成した日本語の不自然さを、意味を保ったまま人間が読みやすく情報密度の高い文章へ推敲するAgent Skillである。対象は技術記事、業務仕様書・PR説明文、エッセイや個人ブログで、Codex、Claude Code、Cursorなどのエージェント環境への導入を想定している。

単語の禁止・置換だけでなく、文の構造を確認して再構築することを中心に据える。最優先の品質条件は次の4点の保持である。

1. 主張、つまり何を言っているか
2. 比重、つまり何を重く扱い、何を軽く扱っているか
3. 言い切りの強さ、つまり断定、推量、可能性の区別
4. 文の働き、つまり評価、説明、依頼、予定、感想の区別

この条件を崩さない範囲で、SVOCMの復元、非生物主語の解体、比喩動詞の具体化、過剰な名詞化の緩和、太字・箇条書き・記号の抑制を行う。比喩を言い換えるときも、「うっかり」「ようやく」「〜てしまった」「地味に」などが持つ感情や評価の含みを残し、元の文章にない主体、原因、条件、数値、例を加えない。

## スキル本体

### 判定するドメイン

`SKILL.md`のfrontmatterは、次の3ドメインを指定または文脈から自動判別すると定義している。

| ドメイン | 対象 | 主な方針 |
| --- | --- | --- |
| `tech` | 技術記事、設計書、コード解説 | 手順と仕組みを具体化し、箇条書き比率を抑える |
| `business` | 仕様書、PR説明、社内レポート、提案書 | 比喩を客観化し、条件・採否基準・責任主体を明確にする |
| `essay` | note、個人ブログ、オピニオン | 体験を大げさな教訓にせず、素直な感情と生活実感を残す |

### 実行手順と出力

処理は、ドメインとモードの判定、構文変換、機械的検査の3段階で構成される。構文変換では、動作主と対象の明確化、指示代名詞の復元、比喩や直訳調の具体化、補足カッコ・不要な空白・絵文字・文末コロン・ダッシュ記号の除去、同一文末の連続抑制を行う。

対話時の出力は、`脱臭・リライト結果`、`主な改善ポイント`、必要な場合だけ`書き手に確かめたい点`の順とする。最後の節は、書き直し時に実際に補うか迷った点だけを最大2件まで示す。

文章の保存時またはフルモードでは、スキル配置ディレクトリ内の`yomiyasu_lint.py`を実行する。ただし、リンターの指摘を消すことよりも、意味保持と文脈上正当な専門用語の維持を優先し、修正試行は最大2回に制限する。

## 付属リンターと検証

### `yomiyasu_lint.py`

[`scripts/yomiyasu_lint.py`](../../_repos/nanaism_yomiyasu/scripts/yomiyasu_lint.py)は外部ライブラリに依存しないPython標準ライブラリ製の決定論的リンターである。コードブロック、引用、表、画像、箇条書きの一部を検査対象から除外し、次の観点を検査する。

- 文字数が300字を超える場合の太字頻度と箇条書き比率
- 同一文末の3連続
- 絵文字、文末コロン、和欧文間の不自然な半角空白
- AI頻出語彙、比喩動詞、定型フィラー
- `AではなくB`という否定対比の候補

スコアは100点からの減点方式で、警告・エラーを5点、情報通知を2点として計算する。`--json`で機械可読の結果を出力でき、`--strict`では警告またはエラーが1件以上ある場合に終了コード1を返す。否定対比は意味を担う場合があるため情報通知にとどまり、`--strict`の失敗条件には含まれない。

```bash
python3 scripts/yomiyasu_lint.py README.md
python3 scripts/yomiyasu_lint.py article.md --strict
```

### コーパス

[`tests/corpus/`](../../_repos/nanaism_yomiyasu/tests/corpus/)には160ファイルの検証用コーパスが収録されている。

| グループ | ファイル数 | 内容 |
| --- | ---: | --- |
| `human` | 16 | 人間が書いた実務文書・エッセイの抜粋 |
| `edge_cases` | 48 | `握る`、`倒す`、`溶かす`、`割る`、`壊れる`などの正当な用例 |
| `raw_ai` | 24 | 8テーマ×3文体の生成文 |
| `blacklist_ai` | 24 | 禁止語を追加した生成文 |
| `yomiyasu_rewritten` | 48 | raw/blacklistを推敲した文書 |

保存済みの[`benchmark_results.json`](../../_repos/nanaism_yomiyasu/tests/corpus/benchmark_results.json)では、平均スコアは`human` 97.4、`edge_cases` 100.0、`raw_ai` 97.6、`blacklist_ai` 97.4、`yomiyasu_rewritten` 97.7となっている。これはリンター固有のヒューリスティックな指標であり、文章の正確性や自然さを直接保証する評価ではない。

[`scripts/benchmark_corpus.py`](../../_repos/nanaism_yomiyasu/scripts/benchmark_corpus.py)は単純なキーワード正規表現とリンターの検出結果を比較し、グループ別の平均スコアを再生成する。`setup_corpus_static.py`は人間文書16本と境界値文書48本を生成し、[`build_corpus.py`](../../_repos/nanaism_yomiyasu/scripts/build_corpus.py)は外部の`claude` CLIを呼び出してraw、ブラックリスト、推敲済みコーパスを作成する。後者は実行時に生成済みMarkdownを削除してから再生成するため、再計測時は対象範囲に注意が必要である。

## 構成

### 主要ディレクトリ・ファイル

| パス | 役割 |
| --- | --- |
| [`SKILL.md`](../../_repos/nanaism_yomiyasu/SKILL.md) | ルートのスキルエントリポイント |
| [`skills/yomiyasu/`](../../_repos/nanaism_yomiyasu/skills/yomiyasu/) | 配布用に同梱されたスキル一式。確認した本体・参照資料・リンターはルート版と同一 |
| [`references/`](../../_repos/nanaism_yomiyasu/references/) | 構文変換原則、AIスロップ語彙カタログ、tech/business/essay別の指針 |
| [`scripts/`](../../_repos/nanaism_yomiyasu/scripts/) | リンター、コーパス生成、静的コーパス準備、ベンチマーク |
| [`tests/corpus/`](../../_repos/nanaism_yomiyasu/tests/corpus/) | 160本の入力・推敲結果・スコアJSON |
| [`evals/comparison_benchmark.md`](../../_repos/nanaism_yomiyasu/evals/comparison_benchmark.md) | 公開可能な文章を使ったBefore/After比較と考察 |
| [`articles/yomiyasu-ai-writing-lint.md`](../../_repos/nanaism_yomiyasu/articles/yomiyasu-ai-writing-lint.md) | 開発背景、AI文体の分析、コーパス設計、導入説明 |
| [`.claude-plugin/`](../../_repos/nanaism_yomiyasu/.claude-plugin/) | Claude Codeのplugin/marketplaceマニフェスト |
| [`README.md`](../../_repos/nanaism_yomiyasu/README.md) | 目的、原則、導入、使い方、構成、参考文献 |
| [`LICENSE`](../../_repos/nanaism_yomiyasu/LICENSE) | MITライセンス |
| [`assets/algo-artis.png`](../../_repos/nanaism_yomiyasu/assets/algo-artis.png) | READMEに掲載するALGO ARTISの画像 |

トップレベルの`SKILL.md`と`skills/yomiyasu/SKILL.md`は同一内容で、参照資料、リンター、Claude Codeマニフェストにも同じ複製構成がある。更新時は両方の内容を同期する必要がある。

## 導入・利用ワークフロー

READMEが案内する導入経路は次の通りである。

1. 推奨は`npx skills add nanaism/yomiyasu`。導入済みの更新は`npx skills update yomiyasu`。
2. CursorやCodexなどでは`npx openskills install nanaism/yomiyasu`の後に`npx openskills sync`を実行する。
3. Claude Codeでは`/plugin marketplace add nanaism/yomiyasu`と`/plugin install yomiyasu@yomiyasu`を使う。
4. Releasesから`yomiyasu.skill`を取得して手動配置する方法もある。

導入後は、対象文を貼って「この文章を読みやすくして」と依頼し、必要なら「技術記事向けに」や`domain tech`のようにドメインを指定する。類似の日本語校正スキルを同時に有効化すると指示が干渉する可能性があるため、READMEは一時的な無効化を勧めている。

## 品質上の特徴と制約

### 特徴

- 禁止語の置換ではなく、主張・比重・断定の強さ・文の働きを固定したうえで構文を再構築する。
- 技術記事、業務文書、エッセイで、比喩の具体化や生活実感の扱いを切り替える。
- 生成結果だけでなく、スキル本文自身を同梱リンターで点検する設計を採っている。
- 物理的な「壊れる」や定着した慣用句など、文脈上正当な表現を機械的に消さない方針がある。

### 制約・注意点

- リンターは正規表現と形式メトリクスによる候補抽出であり、意味保持、事実性、文体の適切さを理解して判定するものではない。最終的な人手確認が必要である。
- コード、引用、表、画像、箇条書きの一部は検査から除外されるため、文書全体の品質を網羅的に保証しない。
- `benchmark_corpus.py`の補助カウンタは、集計側が期待する旧ルール名と現行`yomiyasu_lint.py`のルール名に不一致があり、保存済みJSONでは`metaphor_verbs`、`symbols`、`formatting`が各グループで0になっている。平均スコアとは分けて解釈する必要がある。
- `build_corpus.py`は`claude` CLI、モデル、実行環境に依存する。今回の調査では外部CLIや生成処理は実行していない。
- ルート版と配布用複製版の同期漏れが起きると、導入先によって指示や検査ロジックが変わる可能性がある。

## 参照した代表的なファイル

- [`README.md`](../../_repos/nanaism_yomiyasu/README.md): 目的、7つの変換原則、導入、使い方、構成
- [`SKILL.md`](../../_repos/nanaism_yomiyasu/SKILL.md): 意味保持、構文変換、出力形式、リンター実行条件
- [`references/gemini-syntax.md`](../../_repos/nanaism_yomiyasu/references/gemini-syntax.md): SVOCM、比喩、文末、記号、空白に関する変換原則
- [`references/slop-catalog.md`](../../_repos/nanaism_yomiyasu/references/slop-catalog.md): AI偏愛動詞、直訳調、急増語、メタフィラーの分類
- [`references/domains/`](../../_repos/nanaism_yomiyasu/references/domains/): tech、business、essayのドメイン別指針
- [`scripts/yomiyasu_lint.py`](../../_repos/nanaism_yomiyasu/scripts/yomiyasu_lint.py): 静的検査の実装とCLI
- [`scripts/benchmark_corpus.py`](../../_repos/nanaism_yomiyasu/scripts/benchmark_corpus.py): コーパスの集計方法
- [`tests/corpus/benchmark_results.json`](../../_repos/nanaism_yomiyasu/tests/corpus/benchmark_results.json): HEAD時点の保存済み集計
- [`articles/yomiyasu-ai-writing-lint.md`](../../_repos/nanaism_yomiyasu/articles/yomiyasu-ai-writing-lint.md): 設計背景と検証の説明

このノートディレクトリで作成・変更したファイルは本`README.md`と親のIndexです。ソースレポジトリ、`_repos/`のclone、`mygit`のmanifest、既存ノートは変更していません。
