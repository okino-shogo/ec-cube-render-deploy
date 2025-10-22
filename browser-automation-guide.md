# 🤖 ブラウザ操作AIエージェント用デプロイガイド

## 🎯 タスク概要
EC-CUBEをRenderにデプロイするためのブラウザ操作タスクです。GitHubリポジトリ作成からRenderでのデプロイ完了まで自動化します。

## 📋 実行すべきタスク一覧

### 1. GitHubリポジトリ作成
- **URL**: https://github.com
- **タスク**: 新しいpublicリポジトリを作成
- **リポジトリ名**: `ec-cube-render-deploy`
- **設定**: Public、READMEやライセンスファイルは作成しない

### 2. GitHub Personal Access Token作成
- **パス**: Settings → Developer settings → Personal access tokens → Tokens (classic)
- **権限**: `repo` scope
- **期間**: 30 days
- **名前**: `ec-cube-deploy-token`

### 3. Renderアカウント作成・サービス設定
- **URL**: https://render.com
- **タスク**: 
  - アカウント作成（GitHubアカウントでサインイン推奨）
  - Web Service作成
  - GitHubリポジトリ連携
  - 環境変数設定

## 🔧 必要な設定値

### 環境変数 (Render Dashboard)
```
APP_ENV=prod
APP_SECRET=[32文字のランダム文字列を生成]
ECCUBE_AUTH_MAGIC=[32文字のランダム文字列を生成]
ECCUBE_ADMIN_ROUTE=admin
ECCUBE_LOCALE=ja
ECCUBE_TIMEZONE=Asia/Tokyo
ECCUBE_FORCE_SSL=true
DATABASE_URL=[Renderが自動で設定]
MAILER_DSN=smtp://localhost:1025
```

### Renderサービス設定
```
Name: ec-cube-shop
Runtime: Docker
Branch: main
Root Directory: (空白)
Docker Command: (空白・自動検出)
```

## 📝 事前準備が必要なもの

### ユーザーが提供すべき情報
1. **GitHubユーザー名**: [ここに入力]
2. **希望するリポジトリ名**: `ec-cube-render-deploy` (デフォルト)
3. **Renderサービス名**: `ec-cube-shop` (デフォルト)

### ランダム文字列生成器
以下のコマンドで生成可能：
```bash
# APP_SECRET用
openssl rand -hex 16

# ECCUBE_AUTH_MAGIC用  
openssl rand -hex 16
```

## 🚀 プロンプトテンプレート

以下のプロンプトをブラウザ操作AIエージェントに渡してください：

---

**EC-CUBE Renderデプロイ自動化タスク**

以下の手順でEC-CUBEをRenderにデプロイしてください：

**Phase 1: GitHubリポジトリ作成**
1. GitHub (https://github.com) にアクセス
2. 右上の「+」ボタンから「New repository」を選択
3. Repository name: `ec-cube-render-deploy`
4. Public リポジトリとして作成
5. 「Initialize this repository with:」のチェックは全て外す
6. 「Create repository」をクリック
7. 作成されたリポジトリURLをメモ

**Phase 2: Personal Access Token作成**
1. GitHub右上のプロフィール → Settings
2. 左メニュー最下部「Developer settings」
3. 「Personal access tokens」→「Tokens (classic)」
4. 「Generate new token」→「Generate new token (classic)」
5. Note: `ec-cube-deploy-token`
6. Expiration: 30 days
7. Select scopes: `repo` にチェック
8. 「Generate token」をクリック
9. 表示されたトークンをコピー・保存

**Phase 3: Renderアカウント・サービス作成**
1. Render (https://render.com) にアクセス  
2. 「Get Started for Free」でアカウント作成
3. GitHubアカウントでサインイン
4. 「New +」→「Web Service」を選択
5. 「Connect GitHub」で先ほど作成したリポジトリを選択
6. 以下の設定でサービス作成：
   - Name: `ec-cube-shop`
   - Runtime: Docker
   - Branch: main
   - Root Directory: (空白)

**Phase 4: 環境変数設定**
Environment Variables セクションで以下を追加：
- `APP_ENV` = `prod`
- `APP_SECRET` = `[32文字のランダム文字列]`
- `ECCUBE_AUTH_MAGIC` = `[32文字のランダム文字列]`
- `ECCUBE_ADMIN_ROUTE` = `admin`
- `ECCUBE_LOCALE` = `ja`
- `ECCUBE_TIMEZONE` = `Asia/Tokyo`
- `ECCUBE_FORCE_SSL` = `true`
- `MAILER_DSN` = `smtp://localhost:1025`

**Phase 5: PostgreSQL データベース追加**
1. Renderダッシュボードで「New +」→「PostgreSQL」
2. Name: `ec-cube-database`
3. 作成完了後、データベースURLをコピー
4. Web ServiceのEnvironment Variablesに追加：
   - `DATABASE_URL` = `[コピーしたデータベースURL]`

**Phase 6: デプロイ準備完了確認**
1. 「Create Web Service」をクリック
2. デプロイログを監視
3. 成功時のURLを確認

**重要**: 各フェーズ完了時に、作成されたURL、トークン、設定値を報告してください。

---

## 🔄 ユーザーが並行して実行するコマンド

ブラウザ操作と並行して、以下のコマンドを実行：

```bash
# 1. GitHubリポジトリURLを設定（ブラウザ操作完了後）
git remote add render-deploy https://github.com/[ユーザー名]/ec-cube-render-deploy.git

# 2. 変更をコミット
git add -A
git commit -m "Add Render deployment configuration"

# 3. mainブランチにプッシュ
git branch -M main
git push render-deploy main
# Username: GitHubユーザー名
# Password: Personal Access Token

# 4. プッシュ完了確認
git remote -v
```

## ✅ 完了確認項目

- [ ] GitHubリポジトリが作成され、コードがプッシュされている
- [ ] RenderでWeb Serviceが作成されている
- [ ] PostgreSQLデータベースが作成されている
- [ ] 全ての環境変数が設定されている
- [ ] デプロイが完了し、アプリケーションにアクセス可能
- [ ] 管理画面URL（/admin）が確認できる

## 🚨 トラブルシューティング

**デプロイ失敗時の確認点**:
1. render.yamlファイルがリポジトリのルートにあるか
2. build.shとstart.shが実行可能権限を持っているか
3. 環境変数が正しく設定されているか
4. データベース接続URLが正しいか

**ログ確認方法**:
- Renderダッシュボード → サービス選択 → Logs タブ