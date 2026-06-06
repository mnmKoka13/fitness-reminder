# ユビキタス言語定義

## ドメイン用語

| 日本語 | 英語（コード上の命名） | 定義 |
|--------|----------------------|------|
| 動画 | `video` | InstagramまたはYouTubeの運動動画。URLで参照する |
| 動画リスト | `videoItems` | ユーザーが登録した動画の一覧 |
| リマインダー | `reminder` | 運動を促す毎日の通知 |
| 通知時刻 | `notificationTime` | リマインダーを送信する時刻（時・分） |
| 設定 | `settings` | アプリの設定情報（通知時刻など） |

## UI/UX用語

| 日本語 | 英語 | 定義 |
|--------|------|------|
| 動画リスト画面 | `VideoListView` | アプリ起動直後に表示されるホーム画面 |
| 動画追加画面 | `AddVideoView` | URLを入力して動画を登録する画面 |
| 設定画面 | `SettingsView` | 通知時刻を設定する画面 |
| 動画セル | `VideoCell` / `VideoRow` | リスト内の各動画を表示する行 |
| 追加ボタン | `addButton` | 動画追加画面を開くFAB（右下の＋ボタン） |

## コード上の命名規則

| 種別 | 命名 | 説明 |
|------|------|------|
| モデル | `VideoItem` | 動画1件を表すデータ構造 |
| モデル | `AppSettings` | アプリ設定を表すデータ構造 |
| ViewModel | `VideoListViewModel` | 動画リスト画面のロジック |
| ViewModel | `SettingsViewModel` | 設定画面のロジック |
| Service | `VideoRepository` | 動画データの永続化を担当 |
| Service | `NotificationService` | ローカル通知の管理を担当 |
| Utility | `URLValidator` | URLの形式バリデーションを担当 |

## 英語・日本語対応表

| English | 日本語 |
|---------|--------|
| video | 動画 |
| reminder | リマインダー |
| notification | 通知 |
| settings | 設定 |
| add | 追加 |
| delete | 削除 |
| reorder | 並び替え |
| validate | バリデーション（検証） |
| persist | 永続化 |
| repository | リポジトリ（データ保存・取得層） |
