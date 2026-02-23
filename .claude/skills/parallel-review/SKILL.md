---
name: parallel-review
description: PRを3つの観点から並列レビューするエージェントチームを起動する
disable-model-invocation: true
---

PRをレビューするエージェントチームを作成してください。

3人のレビュアーを生成:
- セキュリティ担当: OWASP Top 10の観点でレビュー
- パフォーマンス担当: N+1クエリ、メモリリーク、不要な再レンダリングをチェック
- テスト担当: テストカバレッジの検証、エッジケースの漏れを指摘

対象: $ARGUMENTS

各レビュアーはreview-checklist Skillの基準に従い、Critical / Warning / Suggestion の3段階で報告すること。
レビュー完了後、リードが3つの観点を統合してサマリーを作成してください。