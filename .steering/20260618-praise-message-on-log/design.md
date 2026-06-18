# 設計書：ログ記録時の称賛メッセージ表示

## 実装アプローチ

### 方針：WorkoutCompletionPopup 内で状態遷移

「やった！」タップ後、ポップアップの中身を称賛表示に切り替え、約2秒後に自動クローズする。
新たなシートを重ねないため、iOS の二重シート問題を回避できる。

#### 状態遷移

```
[waiting] ──「やった！」タップ──→ [praised] ──2秒後──→ onComplete()（ポップアップを閉じる）
[waiting] ──「まだやってない」──→ onDismiss()
```

### 称賛メッセージ

複数パターンを定義し、表示時にランダムで1件を選択する。

```swift
// WorkoutCompletionPopup 内に定義
private static let praiseMessages = [
    "今日も頑張ったね！すごい！",
    "運動できた！その調子！",
    "素晴らしい！継続は力なり！",
    "今日も一歩前進！えらい！",
    "やったね！自分を褒めよう！",
    "完璧！明日も一緒に頑張ろう！",
]
```

## 変更するコンポーネント

### `WorkoutCompletionPopup.swift`（変更）

- `@State private var isCompleted: Bool` を追加
- `@State private var praiseMessage: String` を追加（表示時にランダム選択）
- `isCompleted == false` のとき：既存の確認UI
- `isCompleted == true` のとき：称賛メッセージUI（アイコン＋メッセージ＋自動クローズ）
- 「やった！」タップ時：`isCompleted = true` にセット → `Task { try? await Task.sleep(...); onComplete() }` で2秒後に閉じる

### 変更しないもの

- `FitnessReminderApp.swift`：`onComplete` コールバックの中身（`logToday()` + `isShowingCompletionPopup = false`）は変更なし
- `WorkoutLogViewModel.swift`：変更なし
- その他のファイル：変更なし

## 称賛UIの構成

```
[トロフィーアイコン（大）]
[称賛メッセージテキスト（太字）]
[「閉じる」ボタン（タップで即クローズ）]
[※2秒後に自動クローズ]
```

- アイコン：`trophy.fill`（`SF Symbols`）、ゴールド（`#FFD700`）
- メッセージ：`title2.bold()`
- シートの高さ：既存と同じ `.fraction(0.35)`

## 影響範囲の分析

- 変更は `WorkoutCompletionPopup.swift` 1ファイルのみ
- `onComplete` / `onDismiss` の呼び出し契約は変わらないため、呼び出し元（`FitnessReminderApp.swift`）への影響なし
- 既存のテストへの影響なし（`WorkoutCompletionPopup` の単体テストは存在しない）
