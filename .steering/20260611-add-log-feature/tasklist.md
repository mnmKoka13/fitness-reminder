# タスクリスト：ログ機能

## タスク一覧

### 1. データ層

- [x] `Models/WorkoutLog.swift` を作成する
  - `loggedDates: [String]`（`"yyyy-MM-dd"` 形式）を持つ `Codable` struct
  - 検証: 型定義・コンパイル通過

- [x] `Services/WorkoutLogRepository.swift` を作成する
  - UserDefaults への保存・読み込み・日付追加・日付削除
  - 検証: ユニットテストを書いてパスさせる

### 2. ViewModel層

- [x] `ViewModels/WorkoutLogViewModel.swift` を作成する
  - カレンダー表示用の日付グリッド生成ロジック
  - 「今日ログ済みか」判定
  - ログ追加・削除
  - 表示範囲：当月を含む直近3ヶ月、前月・翌月ナビゲーション
  - 検証: ユニットテストを書いてパスさせる

- [x] `ViewModels/VideoListViewModel.swift` に `videoOpenedAt: Date?` を追加する
  - 検証: コンパイル通過

### 3. View層

- [x] `Views/WorkoutCompletionPopup.swift` を作成する
  - 「やった」「まだやってない」の2択ポップアップ（`.sheet` または `.alert`）
  - 検証: Previewで表示確認

- [x] `Views/WorkoutLogView.swift` を作成する
  - `LazyVGrid` によるカレンダーUI
  - 運動済み日付に `checkmark.circle.fill` を表示
  - ログ済み日付タップ → 確認アラート → 削除
  - 月ナビゲーション（前月・翌月）
  - 検証: Previewで3ヶ月分の表示確認

- [x] `Views/VideoListView.swift` を変更する
  - 動画タップ時に `viewModel.videoOpenedAt = Date()` をセット
  - 検証: コンパイル通過・既存動作に影響なし

- [x] `FitnessReminderApp.swift` を変更する
  - `TabView` 導入（Tab1: 動画リスト、Tab2: ログ）
  - `scenePhase` 監視：フォアグラウンド復帰時にポップアップ表示判定
  - ポップアップ表示後に `videoOpenedAt` をリセット
  - 検証: シミュレーターで既存シート（設定・動画追加）が正常に動作することを確認

### 4. 永続的ドキュメント更新

- [x] `docs/architecture.md` を更新する
  - `WorkoutLogRepository` をシステム構成図・ディレクトリ構成に追記

- [x] `docs/functional-design.md` を更新する
  - ログ機能のデータモデル・画面構成を追記

## 完了条件

- [x] 動画タップ → 外部アプリ → アプリ復帰 → ポップアップが表示される
- [x] 「やった」タップで当日がカレンダーに記録される
- [x] 「まだやってない」タップでポップアップが閉じ、カレンダーに変化なし
- [x] 当日ログ済みの場合はポップアップが表示されない
- [x] ログ画面でログ済み日付をタップすると削除できる
- [x] 3ヶ月より前の月にナビゲーションできない
- [x] 既存機能（通知・動画追加・削除・並び替え・設定）が壊れていない
