# monitor-shell-chinachu

録画サーバー（[Chinachu](https://chinachu.moe/)）のログを監視し、録画の開始・終了を Slack に通知するシェルスクリプト。sensu 等のミドルウェアを使わず、cron 等から直接実行するシンプルな構成。

## 概要

`shell/alert_rec.sh` が `chinachu-operator.stdout.log` を読み、`RECORD`（録画開始）・`FIN`（録画終了）のログ行を検知して Slack Incoming Webhook に通知する。

## 構成

| ファイル | 役割 |
|---|---|
| `shell/alert_rec.sh` | ログ監視 + Slack通知本体のスクリプト |
| `/.github/workflows/ci.yml`（リポジトリルート） | CI設定。`alert_rec.sh` の ShellCheck 等（GitHub Actions はリポジトリルートの `.github/workflows/` しか自動検出しないため、このプロジェクト単体ではなくリポジトリ直下に配置） |
| `.gitignore` | `.env` / `.log` を除外 |

## セットアップ

1. `env.example` をコピーして `.env` を作成し、`SLACK_URL` を実際の Webhook URL に差し替える

   ```
   cp env.example .env
   ```

   `.env` はスクリプトと同じディレクトリ（プロジェクトルート、`shell/` の一つ上）に置く。`.gitignore` で除外済み。

2. `shell/alert_rec.sh` 内の `LOG` 変数を実際のログパスに合わせる（本番用パスはコメントアウトされている）

   ```
   # Prod
   LOG=/usr/local/var/log/chinachu-operator.stdout.log
   # Beta（現状こちらが有効）
   LOG=log/chinachu-operator.stdout.log
   ```

3. cron 等で1分おきに定期実行する（`DATE` によるフィルタが直近1分のログ行を対象にする作りのため）

## 注意点・要確認事項

- Slack 通知先チャンネルは Webhook URL 側の設定に依存（テンプレート内に固定チャンネル指定なし）
- ダッシュボードリンク（`http://192.168.2.100:20772/#!/dashboard/top/`）は環境依存のサンプル値の可能性あり
- `.env` が無い場合・`SLACK_URL` が空の場合はエラーメッセージを標準エラーに出力して何もせず終了する
