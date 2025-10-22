# 🚀 EC-CUBEをRenderにデプロイする手順

## 準備ができているか確認
以下のコマンドを実行して、準備ができているか確認しましょう：

```bash
# 現在の場所を確認
pwd
# 出力例: /Users/okinotakumiware/ec-cube

# ファイルが作成されているか確認
ls -la | grep -E "(render.yaml|build.sh|start.sh)"
# render.yaml, build.sh, start.sh が表示されればOK
```

## GitHubにコードをアップロード

### 1. まず、あなたのGitHub URLを設定
```bash
# ⚠️ 「YOUR_USERNAME」を自分のGitHubユーザー名に変えてください！
# 例: git remote add myrepo https://github.com/takumi-okino/my-ec-cube-shop.git

git remote add myrepo https://github.com/YOUR_USERNAME/my-ec-cube-shop.git
```

### 2. コミット（変更を記録）
```bash
# 変更を記録
git commit -m "Renderデプロイ用の設定を追加"
```

### 3. GitHubにプッシュ（アップロード）
```bash
# 新しいブランチを作成してプッシュ
git checkout -b deploy-branch
git push myrepo deploy-branch
```

このとき、GitHubのユーザー名とパスワードを聞かれます：
- Username: あなたのGitHubユーザー名
- Password: GitHubのPersonal Access Token（次で説明）

## GitHubのPersonal Access Tokenを作る

パスワードの代わりにトークンが必要です：

1. GitHubにログイン
2. 右上のアイコン → Settings
3. 左メニューの一番下「Developer settings」
4. 「Personal access tokens」→「Tokens (classic)」
5. 「Generate new token」→「Generate new token (classic)」
6. Note: `ec-cube-deploy`（好きな名前）
7. Expiration: 30 days
8. Select scopes: `repo`にチェック
9. 「Generate token」
10. **表示されたトークンをコピー**（一度しか表示されません！）

## もう一度プッシュ
```bash
git push myrepo deploy-branch
# Username: あなたのGitHubユーザー名
# Password: コピーしたトークンを貼り付け
```

## 成功したか確認
ブラウザでGitHubのリポジトリページを開いて、ファイルがアップロードされているか確認しましょう。

## 次のステップ: Renderでデプロイ

1. https://render.com にアクセス
2. 「Get Started for Free」でアカウント作成
3. GitHubアカウントでサインイン
4. 「New +」→「Web Service」
5. あなたのリポジトリ `my-ec-cube-shop` を選択
6. Branch: `deploy-branch` を選択
7. 「Create Web Service」

あとは自動でデプロイが始まります！