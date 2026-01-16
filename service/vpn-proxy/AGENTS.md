# VPN Proxy Service - プロジェクトコンテキスト

## サービス概要

WireGuard VPNサーバーは拠点外VPSで運用されており、VPNクライアント間の通信は可能ですが、拠点内のVPN非接続サーバー（開発環境、監視サーバー等）へは直接アクセスできません。

このvpn-proxyサービスを**VPN接続されたサーバー上**で稼働させることで、VPNクライアントから拠点内のVPN非接続サーバーへのアクセスを中継します。

## アーキテクチャ

```
[VPN Client] --VPN--> [VPN Server (VPS)] --VPN--> [vpn-proxy (VPN接続)] --LAN--> [非VPN接続サーバー群]
                                                          ↓
                                                    [Nginx Proxy]
                                                          ↓
                                        ┌─────────────────┼─────────────────┐
                                        ↓                 ↓                 ↓
                                [開発サーバー]      [監視サーバー]       [AIテストサーバー]
                              192.168.100.55    192.168.100.51    192.168.100.56
```

## 解決する課題

| 課題 | 解決策 | 効果 |
|------|--------|------|
| VPN経由で拠点内サーバーにアクセス不可 | VPN接続サーバー上でプロキシを稼働 | VPNクライアントから透過的にアクセス可能 |
| 複数バックエンドサーバーの管理 | Nginxリバースプロキシによる統合管理 | 単一エンドポイントで複数サービスにルーティング |
| アクセス制御とセキュリティ | レート制限、セキュリティヘッダー、SSL対応 | 安全なプロキシ通信 |

## 技術スタック

| コンポーネント | 技術 | バージョン | 用途 |
|------------|------|----------|------|
| Reverse Proxy | Nginx Alpine | latest | HTTPプロキシ、ロードバランシング |
| Monitoring | Node Exporter | latest | システムメトリクス収集（Prometheus連携） |
| Container | Docker Compose | v2 | サービスオーケストレーション |

## 実装状況

### 完了
- [x] Docker Compose定義作成
- [x] Nginx リバースプロキシ設定
  - [x] ベース設定（nginx.conf）
  - [x] デフォルトサーバー（ヘルスチェック、メトリクス）
  - [x] プロキシバックエンド設定例（3サービス）
- [x] Node Exporter統合（Prometheus監視対応）
- [x] セキュリティ設定（レート制限、セキュリティヘッダー）
- [x] WebSocket対応
- [x] 環境変数テンプレート（.env.example）
- [x] 包括的なドキュメント（README.md）
- [x] .gitignore設定
- [x] NAT越し環境への最適化（HTTP通信のみ）

### 今後の拡張
- [ ] TCP/UDPストリームプロキシ対応（SSH、データベース等）
- [ ] 認証機能追加（Basic Auth等、VPN認証の追加層として）
- [ ] アクセスログの集約とGrafanaダッシュボード統合
- [ ] Fail2Banによる自動IP制限
- [ ] 負荷分散（複数バックエンドサーバーへのロードバランシング）
- [ ] 自己署名証明書によるHTTPS化（オプション、VPN内部通信には不要）
- [ ] Cloudflare DNS設定追加（必要に応じて）

## 主要機能

1. **リバースプロキシ**
   - Nginxによる複数バックエンドサーバーへのルーティング
   - ホスト名ベースルーティング対応
   - WebSocket対応（双方向通信）

2. **監視統合**
   - Prometheus Node Exporterによるメトリクス収集
   - `/metrics` エンドポイントで公開
   - システムメトリクス（CPU、メモリ、ディスク、ネットワーク）

3. **セキュリティ**
   - レート制限（10リクエスト/秒、厳格制限3リクエスト/秒）
   - 同時接続数制限（10接続/IP）
   - セキュリティヘッダー（X-Frame-Options、X-Content-Type-Options等）
   - VPN暗号化通信（WireGuardトンネル内でHTTP）

4. **運用性**
   - ヘルスチェックエンドポイント（/health）
   - 詳細なアクセスログ（プロキシ情報含む）
   - 環境別設定（dev/prod）
   - NAT越し環境に最適化（HTTP通信のみ）

## 使用例

### プロキシ設定追加

```bash
# 1. バックエンド設定をコピー
cd nginx/conf.d
cp proxy-backends.conf.example proxy-backends.conf

# 2. 設定を編集して新しいバックエンドを追加
vi proxy-backends.conf

# 3. Nginxリロード
docker compose exec nginx nginx -s reload
```

### VPNクライアントからのアクセス

```bash
# ヘルスチェック
curl http://10.0.0.5/health

# プロキシ経由でバックエンドにアクセス（ホスト名ベース）
curl -H "Host: develop-proxy.vpn.local" http://10.0.0.5/

# メトリクス確認
curl http://10.0.0.5/metrics
```

## 設計指針

1. **モジュール化**: 各バックエンドサーバーは独立した設定ファイルで管理
2. **セキュリティファースト**: デフォルトでレート制限とセキュリティヘッダーを適用
3. **監視可能性**: Prometheus統合によるメトリクス収集
4. **運用容易性**: Docker Compose による一元管理、自動SSL更新

## 関連サービス

- [WireGuard Dashboard](../wgdashboard/) - VPN管理ダッシュボード
- [Monitoring Service](../monitoring/) - Prometheus/Grafana監視基盤
- [Develop Service](../develop/) - 統合開発環境（プロキシ対象）
- [AI Test Service](../ai-test/) - AI実験環境（プロキシ対象）

## トラブルシューティング

### バックエンドサーバーに接続できない

```bash
# ネットワーク疎通確認
docker compose exec nginx ping -c 3 192.168.100.55

# ルーティング確認
docker compose exec nginx ip route

# Nginxエラーログ確認
docker compose logs nginx | grep error
```

### VPNクライアントからアクセスできない

```bash
# VPN接続確認
ping 10.0.0.5

# Firewall確認（vpn-proxyサーバー側）
sudo iptables -L -n -v | grep 80

# Docker ネットワーク確認
docker network inspect vpn-proxy-network
```

## セキュリティ考慮事項

1. **VPN暗号化通信**: WireGuardトンネル内で通信するため、HTTPでも安全
2. **NAT越し制約**: Let's Encrypt使用不可（外部からの80/443アクセス不可）
3. **アクセス制御**: VPNサブネットからのみアクセスを許可するよう設定を推奨
4. **レート制限**: デフォルト設定を環境に応じて調整
5. **ログ監視**: アクセスログを定期的に確認し、不審なアクセスを検出
6. **定期更新**: Docker イメージの定期更新

## パフォーマンス最適化

- Gzip圧縮有効化済み
- プロキシバッファリング最適化
- 適切なタイムアウト設定（AI処理用に長いタイムアウト設定可能）
- WebSocket対応により双方向通信の効率化

## 次のステップ

1. **Prometheus統合**: monitoring サービスのscrape設定に追加
2. **Grafanaダッシュボード**: プロキシメトリクスの可視化
3. **認証機能**: Basic Authの導入検討（VPN認証の追加層として）
4. **Fail2Ban統合**: 不正アクセスの自動ブロック
5. **負荷分散**: 複数バックエンドサーバーへのロードバランシング実装