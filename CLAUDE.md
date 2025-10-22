# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## プロジェクト概要

EC-CUBE 4.3は、Symfony 6.4をベースにしたオープンソースのECプラットフォームです。

**技術スタック**:
- **バックエンド**: PHP 8.1/8.2/8.3, Symfony 6.4
- **データベース**: PostgreSQL 12+, MySQL 8.4.x, SQLite3
- **フロントエンド**: Sass, webpack, gulp, Bootstrap 5, jQuery
- **テスト**: PHPUnit, Codeception

## 開発コマンド

### 環境セットアップ
```bash
# Composerパッケージのインストール
composer install

# Node.jsパッケージのインストール
npm ci

# データベースの作成とセットアップ
bin/console doctrine:database:create
bin/console doctrine:schema:create
bin/console eccube:fixtures:load
```

### フロントエンドビルド
```bash
# Sass + JavaScript のビルド
npm run build

# Gulpによる開発モード (ファイル監視)
npm start

# JavaScriptのみのビルド
npx webpack
```

### Docker環境でのビルド
```bash
# npm ciの実行
docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.nodejs.yml run --rm -T nodejs npm ci

# Sass + JavaScriptのビルド
docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.nodejs.yml run --rm -T nodejs npm run build

# JavaScriptのみのビルド
docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.nodejs.yml run --rm -T nodejs npx webpack
```

### テスト実行

#### PHPUnit (ユニットテスト)
```bash
# すべてのテストを実行
vendor/bin/phpunit

# 特定のグループを除外
vendor/bin/phpunit --exclude-group cache-clear,cache-clear-install,update-schema-doctrine,plugin-service

# 特定のグループのみ実行
vendor/bin/phpunit --group cache-clear

# 特定のテストクラスを実行
vendor/bin/phpunit tests/Eccube/Tests/Web/Admin/Product/ProductControllerTest.php

# 特定のテストメソッドのみ実行
vendor/bin/phpunit --filter testIndex tests/Eccube/Tests/Web/Admin/Product/ProductControllerTest.php
```

#### Codeception (E2Eテスト)
```bash
# E2Eテストの実行
vendor/bin/codecept run acceptance

# 特定のテストファイルを実行
vendor/bin/codecept run acceptance EA01LoginCest
```

### コード品質チェック

```bash
# PHP CS Fixer (コードスタイル修正)
vendor/bin/php-cs-fixer fix

# PHPStan (静的解析)
vendor/bin/phpstan analyse

# Rector (コード自動リファクタリング)
vendor/bin/rector process
```

### Symfony コンソールコマンド

```bash
# キャッシュクリア
bin/console cache:clear

# アセットのインストール
bin/console assets:install --symlink --relative html

# データベーススキーマの更新
bin/console doctrine:schema:update --force

# マイグレーションの実行
bin/console doctrine:migrations:migrate

# カスタムコマンドの一覧
bin/console list eccube
```

## アーキテクチャ

### ディレクトリ構造

```
ec-cube/
├── src/Eccube/          # コアアプリケーションコード
│   ├── Controller/      # コントローラー (Admin/, Mypage/, など)
│   ├── Entity/          # Doctrineエンティティ
│   ├── Repository/      # Doctrineリポジトリ
│   ├── Service/         # ビジネスロジック層
│   ├── Form/            # Symfonyフォームタイプ
│   ├── EventListener/   # イベントリスナー
│   ├── Command/         # コンソールコマンド
│   ├── Security/        # 認証・認可
│   └── Twig/            # Twig拡張
├── app/
│   ├── Customize/       # カスタマイズ用ディレクトリ
│   │   ├── Controller/  # カスタムコントローラー
│   │   ├── Entity/      # カスタムエンティティ
│   │   └── Resource/    # カスタム設定ファイル
│   ├── Plugin/          # プラグイン (各プラグインは独立したバンドル)
│   ├── config/          # アプリケーション設定
│   ├── proxy/entity/    # エンティティトレイトプロキシ
│   └── template/        # Twigテンプレート
├── html/                # 公開ディレクトリ
│   └── template/        # フロントエンドアセット
│       ├── admin/       # 管理画面用
│       └── default/     # フロント画面用
├── tests/               # PHPUnitテスト
└── codeception/         # Codeception E2Eテスト
```

### レイヤーアーキテクチャ

EC-CUBEは典型的なSymfonyのMVCパターンに従っています:

1. **Controller層**: HTTPリクエスト/レスポンスを処理
   - `src/Eccube/Controller/` - コアコントローラー
   - 管理画面は `Admin/` 配下、フロント画面は直接配置

2. **Service層**: ビジネスロジックを実装
   - `src/Eccube/Service/` - 各種サービスクラス
   - 特に重要: `PurchaseFlow/` (注文フロー処理)

3. **Repository層**: データアクセス
   - `src/Eccube/Repository/` - Doctrineリポジトリ
   - カスタムクエリビルダーを含む

4. **Entity層**: データモデル
   - `src/Eccube/Entity/` - ORMエンティティ
   - トレイトによる拡張が可能 (後述)

### エンティティトレイト拡張システム

EC-CUBEの最も重要な設計パターンの一つは、**エンティティトレイトプロキシシステム**です:

- プラグインやカスタマイズでエンティティを拡張する際、エンティティクラスを直接編集せず、トレイトを使用
- トレイトは `app/proxy/entity/` にプロキシクラスとして自動生成される
- `src/Eccube/Kernel.php:322-337` で起動時にプロキシをロード
- これにより、複数のプラグインが同じエンティティを安全に拡張可能

**例**: Productエンティティに新しいフィールドを追加する場合:
1. `app/Customize/Entity/ProductTrait.php` を作成
2. トレイトにプロパティとメソッドを定義
3. キャッシュクリア後、自動的にプロキシが生成される

### プラグインシステム

プラグインは `app/Plugin/` 配下に配置され、それぞれが独立したSymfonyバンドルとして動作:

- **構造**: `app/Plugin/{PluginName}/`
  - `Controller/` - プラグイン専用コントローラー
  - `Entity/` - プラグイン専用エンティティ
  - `Service/` - プラグイン専用サービス
  - `Resource/config/` - 設定ファイル (services.yaml, routes.yaml)
  - `PluginManager.php` - インストール/アンインストール処理

- **ライフサイクル**: `PluginManager.php` で install/uninstall/enable/disable をハンドル
- **ルーティング**: `src/Eccube/Kernel.php:207-220` で有効なプラグインのルートを自動ロード
- **DI設定**: `src/Eccube/Kernel.php:172-175` でサービス定義を自動ロード

### 拡張ポイント (Compiler Pass)

EC-CUBEは以下の拡張ポイントをCompiler Passで提供:

1. **PurchaseFlow** (`src/Eccube/DependencyInjection/Compiler/PurchaseFlowPass.php`)
   - カート・注文フローの各ステップに処理を追加
   - タグ: `ItemPreprocessor`, `ItemValidator`, `ItemHolderValidator`, `DiscountProcessor`, `PurchaseProcessor`

2. **QueryCustomizer** (`src/Eccube/DependencyInjection/Compiler/QueryCustomizerPass.php`)
   - Doctrineクエリビルダーを動的にカスタマイズ
   - 特定のリポジトリメソッドに自動的にWHERE句などを追加可能

3. **EccubeNav** (`src/Eccube/DependencyInjection/Compiler/NavCompilerPass.php`)
   - 管理画面のナビゲーションメニューを拡張

4. **TwigBlock** (`src/Eccube/DependencyInjection/Compiler/TwigBlockPass.php`)
   - Twigテンプレートにブロックを動的に追加

5. **PaymentMethod** (`src/Eccube/DependencyInjection/Compiler/PaymentMethodPass.php`)
   - 支払い方法を追加

### カスタマイズの方針

コアファイル (`src/Eccube/`) は直接編集せず、以下のアプローチを使用:

1. **Customizeディレクトリ**: `app/Customize/` でコアをオーバーライド
   - Controller, Entity, Service などを配置
   - `app/Customize/Resource/config/services.yaml` でDI設定

2. **プラグイン**: 再利用可能な機能は `app/Plugin/` でプラグイン化

3. **イベントリスナー**: Symfonyイベントをフックして処理を追加
   - `EventListener` をCustomizeまたはPluginに配置

4. **テンプレートカスタマイズ**: `app/template/` でTwigテンプレートをオーバーライド

## 日本語対応

- このプロジェクトは日本語が主要言語です
- コメント、ドキュメント、エラーメッセージは日本語で記述
- 変数名、クラス名、メソッド名は英語を使用

## 注意事項

### データベース
- **エンティティ変更後**: 必ずマイグレーションファイルを生成 (`bin/console doctrine:migrations:diff`)
- **本番環境**: `doctrine:schema:update --force` は使用せず、マイグレーションを実行

### キャッシュ
- コンパイラパスやサービス定義の変更後は `bin/console cache:clear` が必要
- プロキシエンティティの変更も同様

### テスト
- 新機能追加時は必ずユニットテストを作成
- E2Eテストは重要なユーザーフローに対して作成
- PHPUnitのグループタグ（`@group`）を適切に付与

### セキュリティ
- CSRF保護は標準で有効
- XSS対策のため、Twigで `{{ variable }}` は自動エスケープ
- SQLインジェクション対策のため、必ずDQLまたはQueryBuilderを使用
