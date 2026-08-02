# Codex Computer Use Watchdog

macOS版Codexで、利用終了後も高い負荷のまま残っているComputer Useを安全に終了するスキルです。

定期監視の作成や、実行間隔、使用モデルの変更もCodexへ自然な言葉で依頼できます。

## できること

- 使用中のComputer Useには触れず、未使用の状態が続いている場合だけ終了
- 既定では10分ごとに監視
- 監視には軽量なGPT-5.6 Lunaを使用
- 実行間隔の変更、一時停止、再開、削除に対応
- 対象が複数あっても再確認は一括で実行
- 監視の実行タスクは完了後に自動で整理

## 必要なもの

- macOS
- Codex desktop app
- Codexへ登録済みのローカルプロジェクト

## インストール

Codexへ次のように依頼します。

```text
$skill-installer を使って https://github.com/yaztak1227/codex-computer-use-watchdog/tree/main/skills/computer-use-watchdog をインストールして
```

インストールしたスキルは次のターンから利用できます。
見つからない場合はCodexを再起動してください。

## 定期監視を作成する

インストール後、Codexへ次のように依頼します。

```text
Computer Use watchdogの定期監視を作って
```

既定では10分間隔、GPT-5.6 Luna、推論「低」、異常時のみ通知する設定で作成されます。

設定を指定することもできます。

```text
Computer Use watchdogを30分ごとに動かして
```

## 設定を変更する

作成後の変更もCodexへ依頼できます。

```text
Computer Use watchdogを10分ごとに変更して
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

```text
Computer Use watchdogを削除して
```

## 手動でインストールする

GitHubから取得して、同梱のインストーラを実行します。

```bash
git clone https://github.com/yaztak1227/codex-computer-use-watchdog.git
cd codex-computer-use-watchdog
./install.sh
```

すでにインストールしているスキルを更新する場合は、次のように実行します。

```bash
./install.sh --force
```

## 安全性

このスキルは、Computer Useが使われていないことを時間を空けて二度確認します。
使用中と判断した場合は何もしません。
終了できない場合も強制終了は行いません。

最初に状態だけ確認したい場合は、Codexへ次のように依頼できます。

```text
Computer Use watchdogで状態だけ確認して。プロセスは終了しないで
```

## License

[MIT](LICENSE)
