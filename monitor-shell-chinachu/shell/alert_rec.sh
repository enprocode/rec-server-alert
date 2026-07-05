#!/bin/bash
set -uo pipefail

## LOG と .env はプロジェクトルート（shell/ の一つ上）からの相対パスなので、
## cron 等どこから呼ばれても解決できるようプロジェクトルートに cd しておく
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

## DATE: 直近1分以内のログ行を対象にする
DATE=$(date -d "1 minute ago" "+%d %b %H:%M:%S")

## Prod
#LOG=/usr/local/var/log/chinachu-operator.stdout.log

## Beta
LOG=log/chinachu-operator.stdout.log

## JSON文字列リテラルに埋め込むための最低限のエスケープ
function json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\r'/}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

## 共通の判定・通知処理
## $1: 検索パターン (RECORD / FIN)
## $2: Slackに表示するステータス文字列
## $3: Slack添付の色
function notify_if_matched() {
  local pattern="$1"
  local status_label="$2"
  local color="$3"

  if [ ! -f "$LOG" ]; then
    echo "LOG file not found: $LOG" >&2
    return
  fi

  local matched
  matched=$(grep "$DATE" "$LOG" | grep "$pattern" || true)

  if [ -z "$matched" ]; then
    return
  fi

  # 直近1分以内に該当イベントがあった場合、該当パターンの最新ログ行を通知に載せる
  local last_log
  last_log=$(printf '%s\n' "$matched" | sed -E 's/^#[[:alnum:]]{4}[[:space:]]//' | tail -n 1)

  slack "$color" "$status_label" "$last_log"
}

function record() {
  notify_if_matched "RECORD" "RECORD" "#dc143c"
}

function fin() {
  notify_if_matched "FIN" "FIN" "good"
}

## $1: Slack添付の色
## $2: Slackに表示するステータス文字列
## $3: 通知に載せるログ本文
function slack() {
  local color="$1"
  local status_label="$2"
  local log_line="$3"

  if [ ! -f .env ]; then
    echo ".env file not found" >&2
    return
  fi

  local url
  url=$(grep -E '^SLACK_URL=' .env | sed -e 's/^SLACK_URL=//')

  if [ -z "${url:-}" ]; then
    echo "SLACK_URL is not set in .env" >&2
    return
  fi

  local color_json status_json log_json
  color_json=$(json_escape "$color")
  status_json=$(json_escape "$status_label")
  log_json=$(json_escape "$log_line")

  local json
  json=$(
    cat <<EOS
  {
    "attachments": [
      {
        "fallback": "REC",
        "color": "${color_json}",
        "title": "Chinachu Dashboard",
        "title_link": "http://192.168.2.100:20772/#!/dashboard/top/",
        "fields": [
          {
            "title": "ステータス",
            "value": "${status_json}"
          },
          {
            "title": "ログ",
            "value": "${log_json}"
          }
        ]
      }
    ]
  }
EOS
  )
  curl -sS -X POST -H 'Content-type: application/json' -d "$json" "$url" \
    || echo "Slack notification failed" >&2
}

record
fin
