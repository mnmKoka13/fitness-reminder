# 開発ガイドライン

## コーディング規約

### 基本方針
- Swift API Design Guidelines に準拠する
- Swift 6 の strict concurrency を有効にする
- `@Observable` マクロを使用する（`ObservableObject` は使わない）

### 型・構造
- データモデルは `struct` を使用する（`class` は避ける）
- `enum` を使ってマジックストリングを排除する
- `protocol` は過度に抽象化せず、テスタビリティが必要な場合のみ導入する

### 非同期処理
- `async/await` を使用する（`completion handler` は使わない）
- MainActor を適切に指定してUI更新をメインスレッドで行う

## 命名規則

| 対象 | 規則 | 例 |
|------|------|----|
| 型（クラス・構造体・列挙型） | UpperCamelCase | `VideoItem`, `VideoListViewModel` |
| 関数・メソッド・変数 | lowerCamelCase | `addVideo()`, `videoItems` |
| 定数 | lowerCamelCase | `defaultNotificationHour` |
| ファイル名 | 型名と一致 | `VideoItem.swift` |
| UserDefaults キー | lowerCamelCase の文字列 | `"videoItems"`, `"notificationHour"` |

## スタイリング規約

- インデント：スペース4つ（Xcodeデフォルト）
- 1行の最大文字数：制限なし（読みやすさ優先）
- `import` は必要なものだけ記載し、アルファベット順に並べる
- SwiftUI の `body` は100行を超えたら子Viewに分割することを検討する

## テスト規約

### テスト対象
ロジックが集中するコンポーネントのみテストを書く。

| 対象 | テスト方針 |
|------|-----------|
| `URLValidator` | 有効・無効なURLのパターンを網羅的にテスト |
| `VideoRepository` | 保存・読み込み・削除・並び替えの動作をテスト |
| Views / ViewModels | テストは書かない（手動動作確認で代替） |

### テストの書き方
- XCTest を使用する
- テスト関数名は `test_[対象]_[条件]_[期待結果]` の形式にする
  - 例：`test_validate_instagramURL_returnsTrue()`
- テストデータはテスト関数内に直書きする（共有フィクスチャは作らない）

## Git規約

### ブランチ戦略
- `main` ブランチに直接コミットする（個人開発のためシンプルに）

### コミットメッセージ
以下のプレフィックスを使用する：

| プレフィックス | 用途 |
|--------------|------|
| `feat:` | 新機能の追加 |
| `fix:` | バグ修正 |
| `docs:` | ドキュメントのみの変更 |
| `refactor:` | 動作を変えないコード変更 |
| `test:` | テストの追加・修正 |
| `chore:` | ビルド設定・依存関係の変更 |

**例：**
```
feat: 動画リスト画面の実装
fix: URLバリデーションで youtu.be を正しく判定するよう修正
docs: product-requirements.md にユーザーストーリーを追加
```

### コミット粒度
- 1コミット1機能・1修正を原則とする
- ドキュメント変更とコード変更は別コミットにする
