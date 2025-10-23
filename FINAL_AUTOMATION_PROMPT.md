# 🤖 EC-CUBE完全自動デプロイ指示書

## ✅ 準備完了事項
- GitHubリポジトリ: https://github.com/okino-shogo/ec-cube-render-deploy
- コードプッシュ: 完了
- ログイン状況: GitHub・Render両方ログイン済み

## 🎯 ブラウザ操作AI用完全自動化プロンプト

```
EC-CUBEをRenderに完全自動デプロイしてください。GitHubリポジトリは準備済みです。

【リポジトリ情報】
URL: https://github.com/okino-shogo/ec-cube-render-deploy
ユーザー: okino-shogo
リポジトリ: ec-cube-render-deploy

【実行タスク】
1. Render（https://render.com）でWeb Service作成
   - New + → Web Service
   - Connect GitHub → okino-shogo/ec-cube-render-deploy選択
   - Name: ec-cube-shop
   - Runtime: Docker（自動検出）
   - Branch: main
   - Root Directory: 空白

2. PostgreSQL作成
   - New + → PostgreSQL  
   - Name: ec-cube-db
   - Database Name: eccube
   - User: eccube

3. Web Serviceの環境変数設定
   APP_ENV=prod
   APP_SECRET=b8f3d9e2a1c4f7e9d6b5c8a2e4f7d9c1
   ECCUBE_AUTH_MAGIC=f7c2e9d1a8b5c4e7f2d9c6a3e1f8d5c2
   ECCUBE_ADMIN_ROUTE=admin
   ECCUBE_LOCALE=ja  
   ECCUBE_TIMEZONE=Asia/Tokyo
   ECCUBE_FORCE_SSL=true
   MAILER_DSN=smtp://localhost:1025

4. データベース接続設定
   - PostgreSQLの「Connect」から接続文字列をコピー
   - Web ServiceのEnvironment Variablesに追加:
     DATABASE_URL=[PostgreSQL接続文字列]

5. デプロイ実行
   - 「Create Web Service」クリック
   - ビルドログ監視
   - デプロイ完了まで待機

【期待される結果】
- アプリURL: https://ec-cube-shop.onrender.com
- 管理画面: https://ec-cube-shop.onrender.com/admin
- ステータス: Live

【重要な注意点】
- render.yamlが自動検出されることを確認
- ビルド時間は5-10分程度
- エラー時はLogsタブでエラー内容を確認
- 初回起動時にDBマイグレーションが実行される

完了時に以下を報告:
✅ Web ServiceのURL
✅ デプロイステータス
✅ 管理画面アクセス可否
✅ エラーログ（もしあれば）
```

## 🔧 事前生成済み設定値

**APP_SECRET**: `b8f3d9e2a1c4f7e9d6b5c8a2e4f7d9c1`
**ECCUBE_AUTH_MAGIC**: `f7c2e9d1a8b5c4e7f2d9c6a3e1f8d5c2`

## 🚀 実行準備完了

1. ✅ コードプッシュ完了
2. ✅ GitHubリポジトリ準備完了
3. ✅ 設定値生成完了
4. ✅ プロンプト準備完了

**次のアクション**: 上記プロンプトをブラウザ操作AIエージェントに渡して実行開始

## 📋 デプロイ完了チェックリスト

### 自動確認項目
- [ ] Renderでサービス作成完了
- [ ] PostgreSQLデータベース作成完了  
- [ ] 環境変数設定完了
- [ ] デプロイ成功
- [ ] アプリケーション起動確認

### 手動確認項目（デプロイ完了後）
- [ ] トップページアクセス可能
- [ ] 管理画面（/admin）アクセス可能
- [ ] データベース接続正常
- [ ] SSL証明書有効

## 🚨 トラブルシューティング

### よくあるエラーと対処法
1. **ビルドエラー**: Logsタブでエラー詳細確認
2. **DB接続エラー**: DATABASE_URLの設定確認
3. **起動エラー**: 環境変数の設定値確認
4. **タイムアウト**: Renderの無料プランの制限確認

### エラー時の対処手順
1. Renderダッシュボード → サービス選択
2. Logsタブでエラー内容確認
3. SettingsタブでEnvironment Variables確認
4. 必要に応じて再デプロイ実行

---

**結論**: すべて準備完了！ブラウザ操作AIに上記プロンプトを渡すだけでデプロイ完了します。