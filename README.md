# Codex Computer Use Watchdog

macOS版CodexのComputer Use補助プロセス `SkyComputerUseService` が、利用終了後もクライアント不在のまま高負荷で残る場合に、安全条件を確認して終了するCodexスキルです。

プロセス監視だけでなく、Codexのスケジュール作成、実行間隔の変更、モデル変更、一時停止・再開・削除まで自然言語で管理できます。

## 特徴

- Computer Useや画面キャプチャを使わずに負荷を判定
- 実行ファイル、bundle ID、署名Team ID、所有ユーザーを検証
- 接続中クライアントや子プロセスがある場合は何もしない
- 1分後に再判定して、条件が変わっていない対象だけに `TERM` を送信
- 対象が複数でも待機プロセスは常に1つ
- `KILL` や広範な `pkill` は使用しない
- 既定のスケジュールは10分ごと、`GPT-5.6 Luna`／推論「低」

## 必要環境

- macOS
- Codex desktop app
- Bash、`launchctl`、`ps`、`lsof`、`codesign`、`plutil`

## Codexのskill-installerで導入する

Codexに次のように依頼します。`<owner>` は、このGitHubリポジトリの所有者名に置き換えてください。

```text
$skill-installer を使って、GitHubリポジトリ <owner>/codex-computer-use-watchdog の skills/computer-use-watchdog をインストールして
```

またはGitHub URLを直接指定できます。

```text
$skill-installer を使って https://github.com/<owner>/codex-computer-use-watchdog/tree/main/skills/computer-use-watchdog をインストールして
```

インストール完了後、次のターンからスキルが利用できます。必要に応じてCodexを再起動してください。

## 同梱インストーラで導入する

リポジトリを取得し、次を実行します。

```bash
./install.sh
```

既定では `${CODEX_HOME:-$HOME/.codex}/skills/computer-use-watchdog` にインストールします。

別のCodexホームへ入れる場合:

```bash
./install.sh --codex-home "$HOME/.codex_lb"
```

既存インストールを更新する場合:

```bash
./install.sh --force
```

`--force` は既存スキルを `$CODEX_HOME/skill-backups` へバックアップしてから更新します。バックアップをスキル検索対象から分離するため、古い版が重複検出されません。

## スケジューラを作成する

スキルを導入した次のターンで、Codexへ依頼します。

```text
Computer Use watchdogを10分ごとに動かすスケジュールを作って。監視だけGPT-5.6 Luna、推論は低にして
```

短くても構いません。

```text
Computer Use watchdogの定期監視を作って
```

スキルは既定で、10分間隔・Luna・低推論・異常時のみ通知する独立ローカルスケジュールを作成します。スケジュールの保存先として、Codexに登録済みのローカルプロジェクトが1つ必要です。

## スケジュールを変更する

```text
Computer Use watchdogを30分ごとに変更して
```

```text
Computer Use watchdogのモデルをTerra、推論を低に変更して
```

```text
Computer Use watchdogを一時停止して
```

```text
Computer Use watchdogを再開して
```

既存のプロンプト、通知条件、プロジェクトなど、依頼されていない設定は維持されます。

## 手動確認

インストール先のスキルディレクトリで実行します。

```bash
/bin/bash scripts/computer-use-watchdog --status
/bin/bash scripts/computer-use-watchdog --dry-run
/bin/bash scripts/computer-use-watchdog --run
```

- `--status`: 読み取り専用の状態確認
- `--dry-run`: 終了候補を判定するが、状態保存やシグナル送信はしない
- `--run`: 候補があれば1つの再確認プロセスを起動して即終了

## 調整項目

環境変数でしきい値を変更できます。

| 変数 | 既定値 | 内容 |
| --- | ---: | --- |
| `CU_WATCHDOG_MIN_AGE_SECONDS` | `60` | 対象にする最小プロセス経過時間 |
| `CU_WATCHDOG_RECHECK_DELAY_SECONDS` | `60` | 再確認までの待機秒数 |
| `CU_WATCHDOG_MIN_CPU` | `2.0` | 平均CPU使用率の下限 |
| `CU_WATCHDOG_STATE_DIR` | macOS Application Support配下 | 状態とログの保存先 |

## 安全性

このスキルはOpenAI署名のComputer Useサービスだけを対象にし、クライアント不在・子プロセスなし・経過時間・CPU負荷を二度確認します。終了要求は `TERM` のみで、応答しないプロセスを強制終了しません。

最初は `--status` または `--dry-run` で挙動を確認してください。

## プライバシー

配布物にはローカルのユーザー名、ホームディレクトリ、メールアドレス、タスクIDなどを含めていません。実際にCodexがローカルスケジュールを生成すると、その端末上の設定にはインストール済みスクリプトの絶対パスが保存されますが、リポジトリへ送信されることはありません。

## License

[MIT](LICENSE)
