# monitor-sensu-epgstation (sensu版)

録画サーバー（EPGStation）のログを [sensu](https://sensu.io/) で監視し、録画の開始・終了・エラーを Slack に通知する設定一式。

## 概要

- EPGStation のログファイル `/home/rec_pc/EPGStation/logs/Operator/system.log` を60秒間隔でチェック
- 以下の3種類のイベントを検知して Slack Incoming Webhook で通知
  - `rec-record`: 録画開始（`recording:` ログを検知）
  - `rec-fin`: 録画終了（`recording finish:` ログを検知）
  - `rec-err`: エラー（`ERROR` ログを検知）

## 構成

| ファイル | 役割 |
|---|---|
| `json/check-rec.json` | sensu のチェック定義（監視対象ログ・間隔・ハンドラの紐付け） |
| `json/handler_rec_slack.json.example` | Slack 通知ハンドラ定義のテンプレート（Webhook URL・使用するテンプレート）。コピーして `handler_rec_slack.json` を作成する（git管理対象外） |
| `json/filter.json` | イベントフィルタ（`action: create` のイベントのみ通知） |
| `json/transport.json` | sensu のトランスポート設定（rabbitmq） |
| `slack_payload/attachement_rec-record.erb` | 録画開始時の Slack 通知テンプレート |
| `slack_payload/attachement_rec-fin.erb` | 録画終了時の Slack 通知テンプレート |
| `slack_payload/attachement_rec-err.erb` | エラー時の Slack 通知テンプレート |

## セットアップ

1. sensu を導入する
2. `json/handler_rec_slack.json.example` をコピーして `json/handler_rec_slack.json` を作成し、`webhook_url` を実際の Slack Incoming Webhook URL に書き換える（`handler_rec_slack.json` は `.gitignore` 済み）
3. 本リポジトリの `json/*.json`（上記で作成した `handler_rec_slack.json` を含む）を sensu のコンフィグディレクトリ（例: `/etc/sensu/conf.d/`）に配置
4. `slack_payload/*.erb` を `handler_rec_slack.json` が参照しているパス（`/etc/sensu/conf.d/slack_payload/`）に配置
5. `json/check-rec.json` の `command` にあるログパス（`/home/rec_pc/EPGStation/logs/Operator/system.log`）を実際の監視対象サーバーに合わせて調整
6. Slack のダッシュボードリンク（各 erb 内の `title_link`、現状 `http://192.168.2.10/#!/dashboard/top/`）も環境に合わせて調整

## 注意点・要確認事項

- `handler_rec_slack.json.example` の `webhook_url` は3箇所ともダミー値。実ファイル `handler_rec_slack.json` を作成した際に**必ず実際の値へ差し替えが必要**
- 通知先チャンネルは各 erb 内で `alert-rec-sensu` に固定
- ダッシュボードリンクの IP（`192.168.2.10`）は環境依存のサンプル値の可能性あり
