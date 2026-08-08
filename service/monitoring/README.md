# Monitoring Stack

Prometheus + Grafana による統合監視基盤

## アクセスURL

- Grafana UI：https://monitoring.abe365.org/grafana/
- Prometheus UI：https://monitoring.abe365.org/prometheus/
- Alertmanager UI：https://monitoring.abe365.org/alertmanager/
- Collector OTLP ポート：4317（gRPC）、4318（HTTP）
- Collector メトリクス：http://localhost:8888/metrics

## 監視対象サービス

| サービス | IP | ポート | メトリクス種別 |
|---------|-----|--------|--------------|
| Dify | 192.168.100.52 | 9100 | Node Exporter |
| WGDashboard | 192.168.100.53 | 9100 | Node Exporter |
| LLM Proxy | 192.168.100.54 | 4000 | LiteLLM Metrics |
| Develop | 192.168.100.55 | 9100 | Node Exporter |
| AI Test | 192.168.100.56 | 11434 | Ollama Metrics |

## セットアップ

```bash
# 環境変数設定
cp .env.example .env
vim .env

# 自己署名証明書の作成（HTTPS）
mkdir -p nginx/ssl && cd nginx/ssl
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 825 \
  -keyout ./key.pem \
  -out ./cert.pem \
  -subj "/CN=monitoring.abe365.org" \
  -addext "subjectAltName=DNS:monitoring.abe365.org"

# 起動
docker-compose up -d

# ログ確認
docker-compose logs -f
```

## Grafanaダッシュボード

初期パスワード: `admin` / `admin`（初回ログイン後に変更してください）

プロビジョニング済みダッシュボード：
- サービス監視ダッシュボード（services-overview）
  - CPU使用率（サービス別）
  - メモリ使用率（サービス別）
  - サービス稼働状況
  - ネットワークトラフィック
  - ディスク使用率

## アラート設定

Alertmanager設定（`config/alertmanager.yml.template`）：
- Slack通知
- Email通知（設定が必要）

環境変数 `SLACK_WEBHOOK_URL` にSlack Webhook URLを設定してください。

## トラブルシューティング

### メトリクスが取得できない

```bash
# Prometheus targets確認
curl http://localhost:9090/api/v1/targets

# 特定サービスのメトリクス確認
curl http://192.168.100.54:4000/metrics
```

### Node Exporterが起動しない

各サービスのdocker-compose.ymlにnode-exporterが追加されていることを確認：

```bash
cd /path/to/service
docker-compose up -d node-exporter
docker-compose logs node-exporter
```
Docker コマンドは docker-compose up -d で起動できます。Grafana UI（http://localhost:3000）で

docker run --rm \
  -v "$(pwd)/generator.yml":/generator/generator.yml:ro \
  -v "$(pwd)/mibs":/root/.snmp/mibs:ro \
  prom/snmp-generator \
  generate
generator generate を実行すると、snmp.yml が生成されます。

生成された snmp.yml を Prometheus スタックに組み込み、SNMP Exporter が参照する設定として利用します。

生成後は Prometheus にて SNMP Exporter のエンドポイントをスクレイプする構成を追加してください。

