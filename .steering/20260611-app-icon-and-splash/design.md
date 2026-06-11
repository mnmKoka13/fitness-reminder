# 設計：アプリアイコン設定・スプラッシュ画面追加

## 実装アプローチ

### 機能 1：アプリアイコン設定

`sips` コマンドでアイコン画像を 1024×1024 にリサイズし、
`Assets.xcassets/AppIcon.appiconset/` に `AppIcon.png` として配置する。
`Contents.json` の `universal / ios` エントリに `"filename": "AppIcon.png"` を追記するだけでよい。

### 機能 2：スプラッシュ画面

`FitnessReminderApp.swift` の `WindowGroup` 内で、
`@State private var isShowingSplash = true` を管理する。

- `isShowingSplash == true` のとき → `SplashView` を表示
- `isShowingSplash == false` のとき → 既存の `TabView` を表示

`SplashView` 内で `Task { try? await Task.sleep(for: .seconds(1)) }` を使い、
1 秒後に `isShowingSplash = false` にする。

バックグラウンド復帰でスプラッシュが再表示されないよう、
`@State` は `App` スコープで持つ（アプリ生存中は `false` のまま維持される）。

---

## 変更するファイル

### 新規作成

| ファイル | 内容 |
|---------|------|
| `Assets.xcassets/AppIcon.appiconset/AppIcon.png` | リサイズ済みアプリアイコン（1024×1024） |
| `Assets.xcassets/SplashIcon.imageset/SplashIcon.png` | スプラッシュ用アイコン画像（1024×1024） |
| `Assets.xcassets/SplashIcon.imageset/Contents.json` | imageset 定義 |
| `Views/SplashView.swift` | スプラッシュ画面 View |

### 変更

| ファイル | 変更内容 |
|---------|---------|
| `Assets.xcassets/AppIcon.appiconset/Contents.json` | `universal / ios` エントリに `"filename": "AppIcon.png"` を追記 |
| `FitnessReminderApp.swift` | `isShowingSplash` を追加し、`WindowGroup` で `SplashView` と `TabView` を切り替え |

---

## SplashView の実装方針

```swift
struct SplashView: View {
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                colors: [Color(hex: "#FFC107"), Color(hex: "#FF7A00")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("SplashIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("Fitness Reminder")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            onFinish()
        }
    }
}
```

`Color(hex:)` は SwiftUI 標準にないため、`Utilities/` に `Color+Hex.swift` として extension を追加する。

---

## FitnessReminderApp の変更方針

```swift
@State private var isShowingSplash = true

var body: some Scene {
    WindowGroup {
        if isShowingSplash {
            SplashView { isShowingSplash = false }
        } else {
            TabView { ... } // 既存コード
        }
    }
}
```

---

## 影響範囲

- 既存の `TabView`・`WorkoutCompletionPopup`・`scenePhase` ロジックに変更なし。
- `SplashView` は独立した View のため、既存コンポーネントへの依存なし。
- `Color+Hex.swift` は `SplashView` 専用で、既存コードには影響しない。
