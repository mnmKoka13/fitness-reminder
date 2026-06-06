# 動画リスト機能改善 設計

## 実装アプローチ

URL登録時に `VideoMetadataFetcher` がタイトル・サムネイルを取得し、`VideoItem` に保存する。
サムネイルは画像データ（`Data`）としてローカルに保存し、アプリ再起動後もオフラインで表示できるようにする。

## 変更するコンポーネント

| コンポーネント | 変更内容 |
|--------------|---------|
| `VideoItem` | `title`・`thumbnailData` フィールドを追加 |
| `VideoListViewModel` | `addVideo` を非同期化、上限チェックを追加 |
| `VideoListView` | 上限メッセージ・FAB無効化を追加 |
| `VideoRowView` | 新規作成（サムネイル + タイトル表示） |
| `VideoMetadataFetcher` | 新規作成（OGP・oEmbed取得） |

## データ構造の変更

### VideoItem（更新）

```swift
struct VideoItem: Identifiable, Codable {
    let id: UUID
    var url: String
    var order: Int
    let createdAt: Date
    var title: String?        // 追加：取得したタイトル（失敗時はnil）
    var thumbnailData: Data?  // 追加：サムネイル画像データ（失敗時はnil）
}
```

サムネイルをURLではなく `Data` で保存する理由：登録後はオフラインでも表示できるようにするため。動画上限10件 × サムネイル最大約20KB = 最大200KB 程度で UserDefaults の許容範囲内。

## 新規コンポーネント

### `VideoMetadataFetcher`（Services/VideoMetadataFetcher.swift）

```swift
struct VideoMetadata {
    let title: String
    let thumbnailData: Data?
}

final class VideoMetadataFetcher {
    func fetch(urlString: String) async -> VideoMetadata?
}
```

#### YouTube の取得処理

oEmbed API を使用する。

```
GET https://www.youtube.com/oembed?url={encodedURL}&format=json
Response: { "title": "...", "thumbnail_url": "..." }
```

1. oEmbed APIでタイトルと `thumbnail_url` を取得
2. `thumbnail_url` から画像データをダウンロード

#### Instagram の取得処理

HTMLの OGP メタタグを解析する。

```
GET https://www.instagram.com/reel/xxx/
Parse: <meta property="og:title" content="...">
       <meta property="og:image" content="...">
```

- ログイン画面が返された場合など取得に失敗したら `nil` を返す
- `nil` の場合は呼び出し側がドメイン名・プラットフォームアイコンで代替表示する

### `VideoRowView`（Views/VideoRowView.swift）

動画セルのレイアウト：

```
┌──────────────────────────────────────┐
│ ┌────────┐  動画タイトル（1行）        │
│ │  サム  │  youtube.com               │
│ │  ネイル │                           │
│ └────────┘                           │
└──────────────────────────────────────┘
```

- サムネイル：60×60pt、角丸、`thumbnailData` がある場合は画像表示、ない場合はプラットフォームアイコン
- タイトル：`title` がある場合はタイトル、ない場合はURL（1行・省略）
- サブテキスト：ドメイン名（`instagram.com` / `youtube.com`）

## VideoListViewModel の変更

```swift
var isAtLimit: Bool { videoItems.count >= 10 }

func addVideo(url: String) async {
    guard !isAtLimit else { return }
    guard URLValidator.isValid(url) else {
        addVideoErrorMessage = "Instagram または YouTube の URL を入力してください"
        return
    }
    // 先にリストに追加（ローディング状態で表示）
    var newItem = VideoItem(url: url, order: videoItems.count)
    videoItems.append(newItem)
    save()
    isShowingAddVideo = false

    // メタデータを非同期取得して更新
    let fetcher = VideoMetadataFetcher()
    if let metadata = await fetcher.fetch(urlString: url),
       let index = videoItems.firstIndex(where: { $0.id == newItem.id }) {
        videoItems[index].title = metadata.title
        videoItems[index].thumbnailData = metadata.thumbnailData
        save()
    }
}
```

## VideoListView の変更

- `isAtLimit` が `true` のとき FAB を半透明・タップ無効にする
- リストの下部に「動画は最大10件まで登録できます」を表示（上限到達時のみ）

## 影響範囲

- `VideoItem` の `Codable` 構造変更により、既存の UserDefaults データは新フィールドが `nil` として読み込まれる（後方互換あり）
- `VideoListViewModel.addVideo` が `async` になるため、呼び出し元の `AddVideoView` で `Task { }` が必要
