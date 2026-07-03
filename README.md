# rec-server-alert

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/enprocode/rec-server-alert/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/enprocode/rec-server-alert/tree/main)

録画サーバー監視・アラート関連のスクリプト集。用途・技術スタックの異なる3つの独立したプロジェクトが含まれる。

## プロジェクト一覧

| プロジェクト | 監視対象 | 方式 | ドキュメント |
|---|---|---|---|
| [`monitor-sensu-epgstation/`](./monitor-sensu-epgstation/) | EPGStation のログ（録画開始・終了・エラー） | sensu + Slack | [docs/monitor-sensu-epgstation.md](./docs/monitor-sensu-epgstation.md) |
| [`monitor-shell-chinachu/`](./monitor-shell-chinachu/) | Chinachu のログ（録画開始・終了） | シェルスクリプト + Slack | [docs/monitor-shell-chinachu.md](./docs/monitor-shell-chinachu.md) |
| [`monitor-prometheus-grafana/`](./monitor-prometheus-grafana/) | サーバー死活監視全般 | Prometheus + Grafana + Alertmanager | [docs/monitor-prometheus-grafana.md](./docs/monitor-prometheus-grafana.md) |

各プロジェクトの詳細な説明・セットアップ手順・注意点は `docs/` 配下のドキュメントを参照。

## 使い分けの目安

- **録画ソフトのログを見て録画イベント（開始/終了/エラー）を通知したい** → `monitor-sensu-epgstation`（sensu導入済み環境）または `monitor-shell-chinachu`（軽量なcron運用）
- **サーバー自体のダウン検知やリソース監視をしたい** → `monitor-prometheus-grafana`

## 共通の注意点

いずれのプロジェクトも、Slack Webhook URL やメールアドレス等がダミー値のまま含まれている。**利用前に `docs/` 配下の各ドキュメント内「注意点・要確認事項」を確認し、実際の値に差し替えること。**

各プロジェクトはそれぞれ別のタイミング（2019〜2022年頃）で作成されたもので、依存関係はない。
