# タスクリスト：アプリアイコン設定・スプラッシュ画面追加

## タスク一覧

凡例：`[ ]` 未着手 / `[x]` 完了

---

### 1. アプリアイコン設定

- [x] 1-1. アプリアイコン画像（1254×1254）を 1024×1024 にリサイズして `AppIcon.appiconset/AppIcon.png` として配置する
  - `sips -z 1024 1024 <元画像パス> --out AppIcon.appiconset/AppIcon.png`
  - 検証: ファイルが生成され、サイズが 1024×1024 であること

- [x] 1-2. `Assets.xcassets/AppIcon.appiconset/Contents.json` を更新する
  - `idiom: universal / platform: ios / size: 1024x1024` エントリに `"filename": "AppIcon.png"` を追記
  - 検証: Xcode で AppIcon にアイコンが表示される

### 2. スプラッシュ画像アセット追加

- [x] 2-1. スプラッシュ用画像（1024×1024 PNG）を `Assets.xcassets/SplashIcon.imageset/SplashIcon.png` として配置する

- [x] 2-2. `Assets.xcassets/SplashIcon.imageset/Contents.json` を作成する
  - `universal` imageset の標準定義
  - 検証: Xcode の Assets で SplashIcon が認識される

### 3. Color+Hex extension 追加

- [x] 3-1. `Utilities/Color+Hex.swift` を作成する
  - `Color(hex:)` イニシャライザを実装する
  - 検証: コンパイル通過

### 4. SplashView 作成

- [x] 4-1. `Views/SplashView.swift` を作成する
  - `#FFC107` → `#FF7A00` のグラデーション背景（上から下）
  - 中央に `SplashIcon` 画像（120×120 pt）
  - 画像下に "Fitness Reminder"（白・bold・title サイズ）
  - `.task` で 1 秒後に `onFinish()` を呼ぶ
  - 検証: Preview で表示確認

### 5. FitnessReminderApp 更新

- [x] 5-1. `FitnessReminderApp.swift` に `isShowingSplash` を追加し、`SplashView` と `TabView` を切り替える
  - 検証: コンパイル通過

### 6. 動作確認

- [x] 6-1. シミュレーターで起動し、スプラッシュ画面が約 1 秒表示された後にメインコンテンツへ遷移することを確認する
- [x] 6-2. ホーム画面でアプリアイコンが正しく表示されることを確認する
- [x] 6-3. バックグラウンドから復帰してもスプラッシュ画面が再表示されないことを確認する
- [x] 6-4. 既存機能（タブ切り替え・通知・動画追加・ログ記録）が壊れていないことを確認する

## 完了条件

- [x] アプリアイコンがホーム画面に表示される
- [x] スプラッシュ画面が約 1 秒表示され、グラデーション背景・白アイコン・白テキストが正しく表示される
- [x] バックグラウンド復帰でスプラッシュが再表示されない
- [x] 既存機能がすべて正常に動作する
