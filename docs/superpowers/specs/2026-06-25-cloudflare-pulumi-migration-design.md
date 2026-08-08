# Cloudflare DNS管理: Terraform → Pulumi 移行設計

## 背景・問題

`cloudflere/` で Cloudflare の DNS レコード（単一 zone `abe365.org`、`cloudflare_dns_record` 52個）を
Terraform（provider v5）で管理しているが、`terraform plan`/`apply` 実行時に断続的に
`401 Unauthorized` (`code 10000: Authentication error`) が発生し、CI が失敗する。

### 根本原因（調査済み）

- 本リポジトリの構文起因（`data.cloudflare_zones` の配列インデックス忘れ等、公式が案内する既知バグ）には該当しない（`zone_id` は固定 `var.zone_id` を参照しているのみ）
- Cloudflare コミュニティで報告されている「800件超のDNSレコードをTerraformで管理すると断続的に401が出る」事例と症状が一致。多数の個別GETリクエストが短時間にバーストすると、Cloudflare側の**認証レイヤーに紐づく別系統のレートリミット**に達し、通常の429ではなく401/`code 10000`を返す
- provider v5 で導入された「SDKによる429自動リトライ」は401には効かない。コミュニティの回避策も「401もリトライ対象にする」という非公式パッチ止まりで、公式のクリーンな解決策は無い
- **Pulumiの公式Cloudflareプロバイダ（`pulumi-cloudflare`）も同じ「1リソース=1API呼び出し」モデル**（同じ upstream API）であり、ツール変更のみでは再発リスクが残る。これはユーザーに明示し、リスクを理解した上でPulumi移行を選択している

## 決定事項

| 項目 | 決定 |
|---|---|
| 移行先 | Pulumi（公式 `pulumi-cloudflare` provider、通常の `cloudflare.DnsRecord` リソースを52個定義） |
| 401対策 | 構造的対策（batch API化）は採用しない。CI側に1回だけの自動リトライのみ追加 |
| 記述言語 | Python（CI実行イメージが `python:3.14` ベースのため追加ランタイム不要） |
| State backend | 既存 S3 バケット `abe365.org` をセルフマネージドバックエンドとして再利用（新規アカウント不要） |
| 認証情報 | 既存の `CLOUDFLARE_API_TOKEN` 環境変数をそのまま使用 |

## アーキテクチャ

```
cloudflere/
  Pulumi.yaml         # project定義
  Pulumi.prod.yaml    # stack設定（zone_id等の非秘密値）
  __main__.py         # 52レコードを cloudflare.DnsRecord として定義
  requirements.txt    # pulumi, pulumi_cloudflare
```

- Stack名: `prod`（単一zoneのため分割しない）
- `pulumi login s3://abe365.org` でS3セルフマネージドバックエンドを使用。key prefixは旧 `cloudflere.tfstate` と衝突しないよう `pulumi/` 以下に配置
- 既存の `records.tf` にある52レコードの値（name / type / content / ttl / proxied）を1:1で `__main__.py` に移植する。新規ロジック・抽象化は追加しない（フラットに52リソースを並べる）

## 認証・Secret

- `CLOUDFLARE_API_TOKEN`: 既存のGitHub Secretを継続使用（pulumi-cloudflareも同名env varを認識）
- `PULUMI_CONFIG_PASSPHRASE`: 新規追加が必要なGitHub Secret。Pulumiはstate暗号化のため何らかのpassphraseを要求する（config内に実際の秘密値が無くても必須）。固定のランダム値を生成し、GitHub Secretsに登録する

## 無停止移行手順（最重要）

ライブで稼働中のDNSレコードを再作成・削除せずにPulumi管理へ切り替える。

1. 現行Terraform stateから zone_id + 各レコードのidを抽出する（`terraform state list` / `terraform show -json` 等）
2. `pulumi import` のbulk importファイル（type / name / id を列挙したJSON）で52レコードをPulumi stateに取り込む。Cloudflare側へは読み取りのみで、create/update/deleteは発生させない
3. `pulumi preview` を実行し、差分（create/update/delete）がゼロであることを確認する。差分が出る場合は `__main__.py` 側の値を実際のレコードに合わせて修正する
4. 差分ゼロを確認できたら本切替：
   - `.github/workflows/cloudflere.yml` をPulumi実行に置き換え
   - 旧 `cloudflere/*.tf` を削除
   - S3上の旧 `cloudflere.tfstate` オブジェクトを削除
   - 並走期間は設けず、確認後すぐに切り替える

## CI変更

- `.github/workflows/cloudflere.yml`:
  - `terraform init` → 不要（Pulumiは`pulumi stack select`程度）
  - `terraform plan -parallelism=1` → `pulumi preview`
  - `terraform apply -auto-approve -parallelism=1` → `pulumi up --yes`
  - `pulumi up` が失敗した場合に**1回だけ自動リトライ**するステップを追加（401再発時の運用負荷軽減のための軽い保険。それ以上のリトライや構造的対策は今回のスコープ外）
- `docker/terraform/Dockerfile`:
  - Pulumi CLI本体のインストールを追加（`pip install pulumi pulumi_cloudflare` はPython SDKのみで、`pulumi` コマンド自体は別途インストールが必要。`curl -fsSL https://get.pulumi.com | sh` 相当の手順を追加）

## テスト・検証

- 移行時: `pulumi preview` の差分ゼロを確認（上記移行手順3）
- 移行後の動作確認: 1レコードだけ値を変更する小さな変更を加え、`pulumi up` で正しく更新されることを確認
- CI: 新しいworkflowが `pulumi preview` → `pulumi up` の流れで正常に完走することを確認

## スコープ外（今回やらないこと）

- Cloudflareのbatch DNS APIを使った構造的な401対策（カスタムDynamic Provider化）。リスクは認識の上で見送り
- 他のCloudflareゾーン・他クラウドのPulumi化（今回は `cloudflere/` の単一zoneのみ）
- Pulumi Cloudへの移行（S3セルフマネージドバックエンドを使うため不要）
