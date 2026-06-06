# 初回実装 設計

## 実装アプローチ

SwiftUI + MVVM で構成する。状態管理には Swift 6 の `@Observable` マクロを使用する。
データ永続化は `UserDefaults` + `Codable`、通知は `UserNotifications` フレームワークで実装する。

## コンポーネントと責務

```
FitnessReminderApp
  └── VideoListView
        ├── VideoListViewModel  ←── VideoRepository
        │                       ←── URLValidator
        ├── AddVideoView
        │     └── VideoListViewModel（共有）
        └── SettingsView
              └── SettingsViewModel  ←── NotificationService
```

## 各コンポーネントの実装詳細

### `VideoItem`（Models/VideoItem.swift）

```swift
struct VideoItem: Identifiable, Codable {
    let id: UUID
    var url: String
    var order: Int
    let createdAt: Date
}
```

### `AppSettings`（Models/AppSettings.swift）

```swift
struct AppSettings: Codable {
    var notificationHour: Int
    var notificationMinute: Int
}
```

デフォルト値：7時00分

### `URLValidator`（Utilities/URLValidator.swift）

対応ドメインのリストと照合してboolを返す純粋関数として実装する。

対応ドメイン：
- `instagram.com`, `www.instagram.com`
- `youtube.com`, `www.youtube.com`, `m.youtube.com`, `youtu.be`

### `VideoRepository`（Services/VideoRepository.swift）

`UserDefaults` への読み書きを担当。`VideoItem` の配列を JSON エンコードして保存する。

| メソッド | 説明 |
|---------|------|
| `load() -> [VideoItem]` | 保存済みリストを読み込む |
| `save(_ items: [VideoItem])` | リストを上書き保存する |

### `NotificationService`（Services/NotificationService.swift）

| メソッド | 説明 |
|---------|------|
| `requestAuthorization() async -> Bool` | 通知権限を要求する |
| `schedule(hour: Int, minute: Int) async` | 毎日指定時刻の通知を登録する（既存を削除してから再登録） |
| `isAuthorized() async -> Bool` | 現在の権限状態を返す |

通知ID：`"dailyFitnessReminder"`（固定）

### `VideoListViewModel`（ViewModels/VideoListViewModel.swift）

```swift
@Observable
final class VideoListViewModel {
    var videoItems: [VideoItem]
    var isShowingAddVideo: Bool
    var isShowingSettings: Bool

    func addVideo(url: String)   // バリデーション後に追加
    func deleteVideo(at offsets: IndexSet)
    func moveVideo(from source: IndexSet, to destination: Int)
}
```

- 初期化時に `VideoRepository.load()` を呼ぶ
- 変更のたびに `VideoRepository.save()` を呼ぶ

### `SettingsViewModel`（ViewModels/SettingsViewModel.swift）

```swift
@Observable
final class SettingsViewModel {
    var notificationHour: Int
    var notificationMinute: Int
    var isNotificationAuthorized: Bool

    func saveSettings() async     // 保存 + 通知再スケジュール
    func requestAuthorization() async
}
```

### `VideoListView`（Views/VideoListView.swift）

- `List` で `videoItems` を表示
- `.onDelete` でスワイプ削除
- `.onMove` でドラッグ並び替え
- 動画セルタップ → `openURL` で外部アプリを開く
- 右下にFAB（＋ボタン）
- ナビゲーションバー右に歯車ボタン
- 動画0件時は空状態View（「＋ボタンから動画を追加してください」）

### `AddVideoView`（Views/AddVideoView.swift）

- `TextField` でURL入力
- 入力値をリアルタイムでバリデーション
- 不正URLは保存ボタンを無効化 + エラーメッセージ表示
- 保存時に `VideoListViewModel.addVideo()` を呼びシートを閉じる

### `SettingsView`（Views/SettingsView.swift）

- `DatePicker`（`.hourAndMinute` スタイル）で時刻選択
- 「保存」ボタンタップで `SettingsViewModel.saveSettings()` を呼ぶ
- 通知未許可時に「通知を許可する」ボタンを表示

## データフロー

```
UserDefaults
    ↓ 起動時 load()
VideoListViewModel.videoItems
    ↓ 表示
VideoListView
    ↓ ユーザー操作（追加・削除・並び替え）
VideoListViewModel（状態更新）
    ↓ save()
UserDefaults
```

## 影響範囲

初回実装のため既存コードへの影響はなし。
