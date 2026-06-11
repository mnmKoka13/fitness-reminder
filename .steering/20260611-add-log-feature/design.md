# 設計：ログ機能

## 実装アプローチ

### 画面構成の変更

現在はルートが `VideoListView` 単体。`TabView` でラップしてログ画面を追加する。

```
TabView
├── Tab 1: VideoListView（動画リスト）
└── Tab 2: WorkoutLogView（ログ・カレンダー）
```

### ポップアップ表示の仕組み

動画タップ後にアプリに戻ったことを検知するため、以下の状態を管理する。

1. 動画タップ時に `videoOpenedAt: Date?` をセット（`VideoListViewModel` が持つ）
2. `FitnessReminderApp` の `scenePhase` が `.active` になったとき以下を判定：
   - `videoOpenedAt` がセットされている
   - 当日のログが未記録
   → 両方満たす場合にポップアップを表示
3. ポップアップ表示後（「やった」「まだやってない」どちらでも）`videoOpenedAt` をリセット

`videoOpenedAt` のタイムアウトは設けない。「一度動画を開いたら、次に戻ってきたとき1回だけ表示する」という挙動にする。

### カレンダーUI

外部ライブラリは使わずSwiftUIの `LazyVGrid` で自前実装する。

- 月単位で表示、前月・翌月ナビゲーションあり
- 表示範囲：直近3ヶ月（当月含む）
- 運動した日はSF Symbolsのチェックマーク（`checkmark.circle.fill`）でハイライト
- 削除：ログ済みの日付をタップ → 確認アラート → 削除

## 追加・変更するファイル

### 新規追加

| ファイル | 役割 |
|---------|------|
| `Models/WorkoutLog.swift` | 運動ログのデータモデル（記録済み日付の配列） |
| `Services/WorkoutLogRepository.swift` | UserDefaults への読み書き |
| `ViewModels/WorkoutLogViewModel.swift` | カレンダー表示・ログ追加・削除のロジック |
| `Views/WorkoutLogView.swift` | カレンダー画面UI |
| `Views/WorkoutCompletionPopup.swift` | 「やった / まだやってない」ポップアップ |

### 変更

| ファイル | 変更内容 |
|---------|---------|
| `FitnessReminderApp.swift` | `TabView` 導入、`scenePhase` 監視、ポップアップ制御 |
| `VideoListView.swift` | 動画タップ時に `videoOpenedAt` をセット |
| `VideoListViewModel.swift` | `videoOpenedAt: Date?` プロパティを追加 |

## データモデル

```swift
// WorkoutLog.swift
struct WorkoutLog: Codable {
    var loggedDates: [String]  // "yyyy-MM-dd" 形式
}
```

日付を文字列（`yyyy-MM-dd`）で保持することで、タイムゾーンのズレを避ける。

## 影響範囲

- 既存の動画リスト・設定・通知機能への影響なし
- `FitnessReminderApp.swift` にルート変更が入るため、既存のシートの動作確認が必要
