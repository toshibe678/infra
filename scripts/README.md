# Scripts

このディレクトリには、インフラ管理を効率化するためのスクリプトを配置しています。

## update-agents-md.sh

AGENTS.mdを自動的に更新するスクリプトです。

### 使い方

#### 手動実行

```bash
# 変更をステージングに追加
git add service/wgdashboard/

# スクリプトを実行
./scripts/update-agents-md.sh

# カテゴリと変更内容を入力
# AGENTS.mdが自動的に更新され、ステージングに追加されます

# コミット
git commit -m "feat: Add WGDashboard with SSL and security"
```

#### Git Hook（自動実行）

`.git/hooks/prepare-commit-msg` が設定されている場合、`git commit` 実行時に自動的に確認プロンプトが表示されます。

```bash
git add service/wgdashboard/
git commit

# プロンプトが表示される:
# 📝 AGENTS.md自動更新
# AGENTS.mdに変更内容を記録しますか？ (y/N):
```

### Git Hook の設定

#### 初回セットアップ（別端末でcloneした場合）

`.git/hooks/` ディレクトリはリポジトリに含まれないため、別端末でcloneした後は以下のコマンドでhookをインストールしてください:

```bash
# リポジトリルートで実行
./scripts/setup-hooks.sh
```

このスクリプトは以下を実行します:
- `scripts/hooks/` 内のhookファイルを `.git/hooks/` にコピー
- 実行権限を自動的に付与
- 既存ファイルがある場合はバックアップを作成

#### 手動セットアップ

セットアップスクリプトを使わない場合は、手動でコピーすることもできます:

```bash
# hookファイルをコピー
cp scripts/hooks/prepare-commit-msg .git/hooks/

# 実行権限を付与
chmod +x .git/hooks/prepare-commit-msg
```

### Git Hook を無効にする

Git Hookを一時的に無効にしたい場合:

```bash
# hookをスキップしてcommit
git commit --no-verify

# または hookファイルの名前を変更
mv .git/hooks/prepare-commit-msg .git/hooks/prepare-commit-msg.disabled
```

## スクリプト一覧

| スクリプト名 | 説明 | 使い方 |
|------------|------|--------|
| update-agents-md.sh | AGENTS.md自動更新 | `./scripts/update-agents-md.sh` |
| setup-hooks.sh | Git Hooks一括セットアップ | `./scripts/setup-hooks.sh` |

## 開発ガイドライン

### 新しいスクリプトを追加する場合

1. **shebang を必ず記述**
   ```bash
   #!/bin/bash
   ```

2. **エラーハンドリング**
   ```bash
   set -e  # エラー時に終了
   set -u  # 未定義変数を参照したら終了
   ```

3. **ドキュメント**
   - スクリプトの先頭にコメントで目的と使い方を記述
   - このREADME.mdに追記

4. **実行権限**
   ```bash
   chmod +x scripts/new-script.sh
   ```

5. **ログ出力**
   - 成功/失敗を明確に表示
   - 色付きで見やすく（GREEN/RED/YELLOW/BLUE）

### Git Hookの注意点

- **無限ループ防止**: AGENTS.md自体がステージングされている場合はスキップ
- **merge/rebase時はスキップ**: 自動マージ時には実行しない
- **ユーザーの確認を求める**: 強制的に実行せず、確認プロンプトを表示
- **--no-verify で回避可能**: 緊急時にはhookをスキップできる

### 新規端末でのセットアップ手順

別のマシンやクリーンな環境でリポジトリを使い始める場合:

```bash
# 1. リポジトリをクローン
git clone <repository-url>
cd infra

# 2. Git Hooksをセットアップ
./scripts/setup-hooks.sh

# 3. 動作確認
echo "# Test" > test.txt
git add test.txt
git commit
# → AGENTS.md更新のプロンプトが表示されればOK

# 4. テストをクリーンアップ
git reset HEAD~1
rm test.txt
```

### テスト方法

```bash
# 変更を作成
echo "# Test" > test.txt
git add test.txt

# スクリプトを実行
./scripts/update-agents-md.sh

# AGENTS.mdが更新されているか確認
git diff AGENTS.md

# 元に戻す
git reset HEAD test.txt AGENTS.md
rm test.txt
```

## トラブルシューティング

### スクリプトが実行できない

```bash
# 実行権限を確認
ls -l scripts/update-agents-md.sh

# 実行権限を付与
chmod +x scripts/update-agents-md.sh
```

### Git Hookが動作しない

```bash
# hookファイルの存在確認
ls -l .git/hooks/prepare-commit-msg

# 実行権限を確認
chmod +x .git/hooks/prepare-commit-msg

# hookが無効になっていないか確認
git config core.hooksPath
# 出力がない、または .git/hooks であればOK
```

### AGENTS.mdの形式が崩れた

```bash
# バックアップから復元
cp AGENTS.md.bak AGENTS.md

# または git で元に戻す
git checkout AGENTS.md
```

## セキュリティ

- スクリプトは常にコードレビューしてから実行してください
- 外部からダウンロードしたスクリプトは内容を確認してから実行
- パスワードや機密情報を含むスクリプトはgitに含めない（.gitignore設定）

## 今後の拡張

- [ ] AI（LLM）を使った変更内容の自動サマリ
- [ ] AGENTS.mdの構造化データ化（YAML/JSON）
- [ ] 変更履歴の可視化ツール
- [ ] Slackへの通知統合
- [ ] CIパイプラインとの統合
