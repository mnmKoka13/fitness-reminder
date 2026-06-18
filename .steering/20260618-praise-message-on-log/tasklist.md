# タスクリスト：ログ記録時の称賛メッセージ表示

## タスク

### T1. WorkoutCompletionPopup に称賛機能を追加
**ファイル：** `FitnessReminder/Views/WorkoutCompletionPopup.swift`

- [x] `isCompleted: Bool` の `@State` を追加
- [x] `praiseMessage: String` の `@State` を追加（称賛メッセージ配列をランダム選択）
- [x] 称賛メッセージ配列（6パターン）を `private static let` で定義
- [x] `body` の表示を `isCompleted` で分岐（確認UI / 称賛UI）
- [x] 「やった！」タップ時：`praiseMessage` をセット → `isCompleted = true` → `Task.sleep(2秒)` → `onComplete()`
- [x] 称賛UI：トロフィーアイコン（`trophy.fill`、ゴールド）＋メッセージ＋「閉じる」ボタン
- [x] `#Preview` が壊れていないことを確認

## 完了条件

- `WorkoutCompletionPopup.swift` のみ変更されている
- 「やった！」タップ → 称賛UI表示 → 2秒後に自動クローズ
- 「まだやってない」タップ → 従来通り即クローズ
- 「閉じる」ボタンタップ → 即クローズ
