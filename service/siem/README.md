# SIEM Stack (Elastic Stack)

Elasticsearch + Kibana + Logstash によるログ集約・検索基盤（開発用構成）

## 概要

Elastic Stack（Elasticsearch, Logstash, Kibana）を用いた最小構成のSIEM環境です。
Beats/TCPでログを受け取り、Logstashで処理してElasticsearchに格納し、Kibanaで可視化します。

**注意**: 本構成は開発用です（`xpack.security.enabled=false` で認証無効）。
外部公開する場合は認証・SSL設定を別途検討してください。

## サービス構成

### コンポーネント

| サービス | 説明 | ポート |
|---------|------|--------|
| elasticsearch | 検索・保存エンジン（シングルノード） | 9200 |
| kibana | 可視化・管理UI | 5601 |
| logstash | ログ収集・変換パイプライン | 5044 (Beats), 50000 (TCP), 9600 (監視API) |
| node-exporter | システムメトリクス収集 | 9100 |

### 依存関係

- kibana → elasticsearch
- logstash → elasticsearch

## セットアップ手順

### 1. サービスの起動

```bash
docker compose up -d
```

### 2. ログの確認

```bash
docker compose logs -f
```

## アクセス方法

サービス起動後、以下のURLでアクセス可能です：

- **Kibana**: http://localhost:5601
- **Elasticsearch API**: http://localhost:9200

## ログ投入方法

- **Beats** (Filebeat等): `localhost:5044` へ転送
- **TCP (JSON Lines)**: `localhost:50000` へ送信（`logstash/pipeline/logstash.conf` の `tcp` input）

投入されたログは `logs-%{+YYYY.MM.dd}` インデックスにElasticsearchへ格納されます。

## データ永続化

以下のボリュームにデータが保存されます：

- `esdata`: Elasticsearchデータ（Docker named volume）

## 設定ファイル

- `logstash/config/logstash.yml`: Logstash全体設定（HTTP bind, モニタリング有無）
- `logstash/pipeline/logstash.conf`: input/filter/output パイプライン定義

## トラブルシューティング

### サービスが起動しない

```bash
# コンテナの状態確認
docker compose ps

# ログの確認
docker compose logs elasticsearch
docker compose logs logstash
```

### Elasticsearchのヘルスチェック

```bash
curl -fsS http://localhost:9200/_cluster/health?pretty
```

## 参考リンク

- [Elastic Stack公式ドキュメント](https://www.elastic.co/guide/index.html)
- [Logstash設定リファレンス](https://www.elastic.co/guide/en/logstash/current/configuration.html)
