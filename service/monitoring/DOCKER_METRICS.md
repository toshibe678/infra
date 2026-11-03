# Docker Daemon Metrics設定

Docker DaemonからPrometheusメトリクスを収集するための設定手順

## 設定手順

### 1. Docker Daemonの設定

各サービスホストで `/etc/docker/daemon.json` にメトリクス設定を追加:

```json
{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
```

### 2. Dockerサービスの再起動

```bash
sudo systemctl restart docker
```

### 3. メトリクスの確認

```bash
curl http://localhost:9323/metrics
```

## 収集されるメトリクス

- `engine_daemon_container_*`: コンテナ統計
- `engine_daemon_image_*`: イメージ統計
- `engine_daemon_network_*`: ネットワーク統計
- `engine_daemon_volume_*`: ボリューム統計
- `engine_daemon_health_checks_*`: ヘルスチェック統計

## トラブルシューティング

### メトリクスにアクセスできない

```bash
# Dockerサービスの状態確認
sudo systemctl status docker

# daemon.json構文確認
sudo cat /etc/docker/daemon.json | jq

# ファイアウォール確認
sudo ufw status
sudo ufw allow 9323/tcp
```

### Prometheusからスクレイプできない

```bash
# 各ホストから接続テスト
curl http://192.168.100.52:9323/metrics
curl http://192.168.100.53:9323/metrics
curl http://192.168.100.54:9323/metrics
curl http://192.168.100.55:9323/metrics
curl http://192.168.100.56:9323/metrics
```

## セキュリティ考慮事項

本番環境では、以下のセキュリティ対策を推奨:

1. **ファイアウォール設定**
   ```bash
   # Prometheusホストからのみ許可
   sudo ufw allow from 192.168.100.51 to any port 9323
   ```

2. **TLS認証の追加**（より厳密な環境）
   - Docker Daemonにクライアント証明書認証を設定

3. **メトリクスエンドポイントの制限**
   - リバースプロキシで認証追加
   - 内部ネットワークに限定
