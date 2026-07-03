# monitor-prometheus-grafana

Prometheus + Grafana + Alertmanager による、録画サーバーを含むホスト全般のインフラ監視スタック（Docker Compose構成）。個別のアラート内容ではなく、サーバー死活監視（ダウン検知）を担う。

## 概要

- `node-exporter` で各ホストのメトリクスを収集
- `prometheus` がメトリクスを収集・監視ルールを評価
- `alertmanager` がアラートを Slack / メールに通知
- `grafana` でメトリクスを可視化

## 構成

| ファイル・ディレクトリ | 役割 |
|---|---|
| `docker-compose.yml` | prometheus / grafana / alertmanager を起動するメインの compose ファイル |
| `target_config/docker-compose.yml` | 監視対象ホスト側で動かす `node-exporter` の compose ファイル |
| `prometheus/prometheus.yml` | Prometheus 本体設定（スクレイプ間隔、監視対象ターゲット） |
| `prometheus/alert.rules` | アラートルール（`instance_down`: 5分間応答なしで検知） |
| `prometheus/node.yml` | node-exporter の監視対象をファイルベースで追加登録する設定 |
| `alertmanager/config.yml.example` | アラート通知先（Slack Webhook / メール）とグルーピング設定のテンプレート。コピーして `config.yml` を作成する（git管理対象外） |
| `grafana/grafana.env` | Grafana の起動時環境変数（ドメイン・ポート等、秘密情報なし・git管理対象） |
| `grafana/grafana.secret.env.example` | Grafana 管理者アカウントのテンプレート。コピーして `grafana.secret.env` を作成する（git管理対象外） |

## セットアップ

1. 監視対象ホストで、`docker network create sample-network` を実行したうえで `target_config/docker-compose.yml` を使って `node-exporter` を起動
2. 監視サーバー側で外部 volume を作成: `docker volume create metrics_data` / `docker volume create grafana_data`
3. `grafana/grafana.secret.env.example` をコピーして `grafana/grafana.secret.env` を作成し、`GF_SECURITY_ADMIN_PASSWORD` を実際の値に差し替える（デフォルトの `admin/admin` のまま公開しないこと）
4. `alertmanager/config.yml.example` をコピーして `alertmanager/config.yml` を作成し、`slack_api_url` と `email_configs.to` を実際の値に書き換える（`config.yml` は `.gitignore` 済み）
5. `prometheus/prometheus.yml` の `targets` を実際の監視対象ホストに書き換える
6. ルートの `docker-compose.yml` で `prometheus` / `grafana` / `alertmanager` を起動

## 注意点・要確認事項

- `prometheus/prometheus.yml` の `job_name: prometheus` の対象 `your_prometheus.com:9090` はダミー値（要書き換え）
- `job_name: node` の静的ターゲット `pve2-rec:9100` は実ホスト名の可能性あり。サンプル値ではなく実際の監視対象かどうか要確認
- `alertmanager/config.yml.example` の `slack_api_url` はマスクされたサンプル値、`smtp_from` / `email_configs.to` も `example.com` のダミーアドレス。実ファイル `config.yml` を作成した際に**必ず実際の値へ差し替えが必要**
- 各コンポーネントのイメージバージョンは固定済み（Prometheus `v3.12.0` / Alertmanager `v0.33.0` / Grafana `13.1.0` / node-exporter `v1.11.1`、いずれも本ドキュメント更新時点の最新安定版）。**Prometheus は 2.x系から 3.x系への大型メジャーアップデートを含むため、既存の2.x系運用からアップグレードする場合は事前に [Prometheus 3.0 の変更点](https://prometheus.io/docs/prometheus/latest/migration/) を確認し、ステージング等で動作確認したうえで適用すること**
- `metrics_data` / `grafana_data` / `sample-network` はいずれも `external: true` 指定のため、`docker-compose up` 前に上記セットアップ手順の volume/network 作成コマンドを事前に実行しておく必要がある（作成し忘れると起動時にエラーになる）
- README のタイトルに typo あり（`alert_monitoring_bata` → `alert_monitoring_beta`）。今回のREADME刷新で修正済み
