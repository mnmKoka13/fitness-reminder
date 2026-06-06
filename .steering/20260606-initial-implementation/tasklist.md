# 初回実装 タスクリスト

## 進捗状況

凡例：`[ ]` 未着手 / `[x]` 完了

---

## Phase 1: Xcodeプロジェクトセットアップ

- [x] 1-1. Xcodeで新規プロジェクトを作成する（App テンプレート、SwiftUI、Swift）
- [x] 1-2. Bundle Identifier を設定する（例：`com.kokado.FitnessReminder`）
- [x] 1-3. Deployment Target を iOS 17.0 に設定する
- [x] 1-4. ディレクトリ構造を作成する（Models / ViewModels / Views / Services / Utilities）
- [x] 1-5. `Info.plist` に通知関連の設定を確認する（UserNotifications は特別なキー不要）

## Phase 2: モデル・ユーティリティ実装

- [x] 2-1. `VideoItem.swift` を実装する（`Identifiable`, `Codable`）
- [x] 2-2. `AppSettings.swift` を実装する（`Codable`、デフォルト7:00）
- [x] 2-3. `URLValidator.swift` を実装する（Instagram / YouTube ドメイン判定）
- [x] 2-4. `URLValidatorTests.swift` を実装する（有効・無効URLのパターン網羅）

## Phase 3: サービス層実装

- [x] 3-1. `VideoRepository.swift` を実装する（`load()` / `save()`）
- [x] 3-2. `VideoRepositoryTests.swift` を実装する（CRUD操作の確認）
- [x] 3-3. `NotificationService.swift` を実装する（権限要求・スケジュール・状態確認）

## Phase 4: ViewModel実装

- [x] 4-1. `VideoListViewModel.swift` を実装する（`addVideo` / `deleteVideo` / `moveVideo`）
- [x] 4-2. `SettingsViewModel.swift` を実装する（`saveSettings` / `requestAuthorization`）

## Phase 5: View実装

- [x] 5-1. `VideoListView.swift` を実装する（リスト表示・空状態・FAB・歯車ボタン）
- [x] 5-2. `AddVideoView.swift` を実装する（URL入力・バリデーション表示・保存）
- [x] 5-3. `SettingsView.swift` を実装する（時刻ピッカー・通知許可ボタン）
- [x] 5-4. `FitnessReminderApp.swift` を修正する（エントリーポイントの調整）

## Phase 6: 結合確認

- [ ] 6-1. シミュレーターで動作確認する（動画追加・削除・並び替え）
- [ ] 6-2. シミュレーターで通知動作を確認する
- [ ] 6-3. アプリ再起動後もデータが保持されていることを確認する
- [ ] 6-4. 不正URLのバリデーションが正しく動作することを確認する
- [ ] 6-5. 動画タップでInstagram / YouTube / Safariが開くことを確認する

## 完了条件

`requirements.md` の受け入れ条件がすべてチェックされた状態。
