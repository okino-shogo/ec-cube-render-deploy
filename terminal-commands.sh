#!/bin/bash

# EC-CUBEデプロイ用ターミナルコマンド
# ブラウザ操作AIがGitHubリポジトリを作成した後に実行

echo "🚀 EC-CUBEデプロイ用コマンド実行スクリプト"
echo ""

# ユーザー入力
read -p "GitHubユーザー名を入力してください: " GITHUB_USERNAME
read -p "作成されたリポジトリ名を入力してください [ec-cube-render-deploy]: " REPO_NAME
REPO_NAME=${REPO_NAME:-ec-cube-render-deploy}

echo ""
echo "設定内容:"
echo "- GitHubユーザー名: $GITHUB_USERNAME"
echo "- リポジトリ名: $REPO_NAME"
echo ""

# リモートリポジトリ追加
echo "📁 リモートリポジトリを追加中..."
git remote add deploy https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# 現在の変更を確認
echo "📋 変更内容を確認中..."
git status

# コミット
echo "📝 変更をコミット中..."
git add -A
git commit -m "Add Render deployment configuration

- render.yaml: Render service configuration
- Dockerfile.render: Docker image for deployment  
- build.sh: Build script for dependencies
- start.sh: Application start script
- .env.prod: Production environment template
- apache-config.conf: Apache configuration"

# ブランチをmainに変更
echo "🌿 メインブランチに切り替え中..."
git branch -M main

# プッシュ
echo "⬆️  GitHubにプッシュ中..."
echo "GitHubのパスワードまたはPersonal Access Tokenの入力が必要です"
git push deploy main

echo ""
echo "✅ デプロイ準備完了！"
echo "ブラウザ操作AIエージェントでRenderのセットアップを続行してください。"
echo ""
echo "📎 リポジトリURL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"