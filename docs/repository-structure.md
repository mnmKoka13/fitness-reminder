# リポジトリ構造定義書

## ディレクトリ構成

```
fitness-reminder/
├── CLAUDE.md                          # Claude Code 設定・開発ルール
├── docs/                              # 永続的ドキュメント
│   ├── product-requirements.md
│   ├── functional-design.md
│   ├── architecture.md
│   ├── repository-structure.md
│   ├── development-guidelines.md
│   ├── glossary.md
│   └── images/                        # 図表用画像（必要な場合のみ）
├── .steering/                         # 作業単位のドキュメント
│   └── [YYYYMMDD]-[開発タイトル]/
│       ├── requirements.md
│       ├── design.md
│       └── tasklist.md
└── FitnessReminder/                   # Xcodeプロジェクト
    ├── FitnessReminder.xcodeproj/
    ├── FitnessReminder/               # アプリソースコード
    │   ├── FitnessReminderApp.swift   # アプリエントリーポイント
    │   ├── Models/
    │   │   ├── VideoItem.swift
    │   │   └── AppSettings.swift
    │   ├── ViewModels/
    │   │   ├── VideoListViewModel.swift
    │   │   └── SettingsViewModel.swift
    │   ├── Views/
    │   │   ├── VideoListView.swift
    │   │   ├── VideoRowView.swift
    │   │   ├── AddVideoView.swift
    │   │   └── SettingsView.swift
    │   ├── Services/
    │   │   ├── VideoRepository.swift
    │   │   ├── VideoMetadataFetcher.swift
    │   │   └── NotificationService.swift
    │   ├── Utilities/
    │   │   └── URLValidator.swift
    │   ├── Assets.xcassets/           # アイコン・カラーアセット
    │   └── Info.plist
    └── FitnessReminderTests/          # ユニットテスト
        ├── URLValidatorTests.swift
        └── VideoRepositoryTests.swift
```

## ディレクトリの役割

### `docs/`
アプリ全体の設計を定義する永続的ドキュメント。基本設計の変更時のみ更新する。

### `.steering/`
特定の開発作業における作業ドキュメント。作業ごとに新しいディレクトリを作成し、完了後も履歴として保持する。

### `FitnessReminder/FitnessReminder/`
アプリのソースコード本体。役割ごとにディレクトリを分割する。

| ディレクトリ | 役割 |
|------------|------|
| `Models/` | データ構造の定義（`Codable` 準拠） |
| `ViewModels/` | ビジネスロジック・状態管理（`@Observable`） |
| `Views/` | SwiftUI の画面コンポーネント |
| `Services/` | 外部システム（UserDefaults・通知）との連携 |
| `Utilities/` | 汎用ロジック（バリデーション等） |

### `FitnessReminderTests/`
ユニットテスト。ロジックが集中する `URLValidator` と `VideoRepository` を対象とする。

## ファイル配置ルール

- 1ファイル1クラス/構造体を原則とする
- ファイル名はクラス名・構造体名と一致させる
- View と ViewModel は1対1で対応させる
- テストファイルは対象ファイル名 + `Tests.swift` の命名にする
