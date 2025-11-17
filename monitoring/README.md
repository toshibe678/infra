Collector OTLP ポート：4317（gRPC）、4318（HTTP） → OTLP クライアントが接続可

Collector メトリクス：http://localhost:8888/metrics

Prometheus UI：http://localhost:9090

Grafana UI：http://localhost:3000

Alertmanager UI：http://localhost:9093
Docker コマンドは docker-compose up -d で起動できます。Grafana UI（http://localhost:3000）で

docker run --rm \
  -v "$(pwd)/generator.yml":/generator/generator.yml:ro \
  -v "$(pwd)/mibs":/root/.snmp/mibs:ro \
  prom/snmp-generator \
  generate
generator generate を実行すると、snmp.yml が生成されます。

生成された snmp.yml を Prometheus スタックに組み込み、SNMP Exporter が参照する設定として利用します。

生成後は Prometheus にて SNMP Exporter のエンドポイントをスクレイプする構成を追加してください。