# 🤖 ブラウザ操作AIエージェント用プロンプト

## 即座に使えるプロンプト

```
EC-CUBEをRenderにデプロイする作業を自動化してください。

【必要な作業】
1. GitHubで新しいリポジトリ「ec-cube-render-deploy」を作成（Public）
2. GitHub Personal Access Token を作成（repo権限、30日間）
3. Renderアカウント作成（GitHubでサインイン）
4. RenderでWeb Service作成、GitHubリポジトリと連携
5. PostgreSQLデータベース作成
6. 環境変数を設定
7. デプロイ実行

【URL】
- GitHub: https://github.com
- Render: https://render.com

【設定値】
リポジトリ名: ec-cube-render-deploy
サービス名: ec-cube-shop
Runtime: Docker
Branch: main

【環境変数】
APP_ENV=prod
APP_SECRET=[ランダム32文字生成]
ECCUBE_AUTH_MAGIC=[ランダム32文字生成]
ECCUBE_ADMIN_ROUTE=admin
ECCUBE_LOCALE=ja
ECCUBE_TIMEZONE=Asia/Tokyo
ECCUBE_FORCE_SSL=true
MAILER_DSN=smtp://localhost:1025
DATABASE_URL=[PostgreSQL作成後に自動設定]

【重要】各ステップ完了時に結果を報告してください：
- GitHubリポジトリURL
- Personal Access Token
- RenderサービスURL
- データベース接続情報
```

## 必要な情報（事前に確認）

### ユーザーから取得が必要な情報
1. **GitHubユーザー名**: [          ]
2. **メールアドレス**: [          ] （Render登録用）

### 自動生成が必要な値
```bash
# APP_SECRET（32文字）
openssl rand -hex 16

# ECCUBE_AUTH_MAGIC（32文字）  
openssl rand -hex 16
```

## 並行実行するターミナルコマンド

ブラウザ操作でリポジトリ作成完了後、以下を実行：

```bash
# 1. リモートリポジトリ追加
git remote add deploy https://github.com/[ユーザー名]/ec-cube-render-deploy.git

# 2. コミット＆プッシュ
git add -A
git commit -m "Add Render deployment files"
git branch -M main
git push deploy main
```

## 期待される結果

✅ **完了時に得られるもの**:
- 稼働中のEC-CUBEサイト（例: https://ec-cube-shop.onrender.com）
- 管理画面アクセスURL（例: https://ec-cube-shop.onrender.com/admin）
- データベース接続情報
- デプロイ用のGitHubリポジトリ