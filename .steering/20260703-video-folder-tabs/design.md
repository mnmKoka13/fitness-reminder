# 動画リストのフォルダ分け機能 設計

## 実装アプローチ

動画を分類する `VideoFolder` モデルを新設し、`VideoItem` に `folderId` を追加して動画とフォルダを紐づける。
`VideoListView` の上部に横スクロールのフォルダタブバーを追加し、選択中のフォルダ（または「すべて」）で動画一覧をフィルタリング表示する。
フォルダの永続化は `VideoRepository` と同じパターンで `VideoFolderRepository` を新設し、`UserDefaults` に保存する。

## 変更するコンポーネント

| コンポーネント | 変更内容 |
|--------------|---------|
| `VideoItem` | `folderId: UUID?` を追加（後方互換のため Optional。新規作成時は必須値として渡す） |
| `VideoFolder` | 新規作成（フォルダのモデル） |
| `VideoFolderRepository` | 新規作成（フォルダの永続化・初回デフォルトフォルダ生成） |
| `VideoListViewModel` | フォルダ一覧・選択中フォルダの管理、フィルタリング、フォルダCRUD、上限チェックのフォルダ単位化、既存データ移行処理を追加 |
| `VideoListView` | フォルダタブバーの表示、表示リストのフィルタ、上限メッセージ・FABのフォルダ単位化 |
| `FolderTabBarView` | 新規作成（フォルダタブ表示・追加ボタン・編集/削除メニュー） |
| `AddVideoView` | 追加先フォルダを選択する Picker を追加 |

## データ構造の変更

### VideoFolder（新規）

```swift
struct VideoFolder: Identifiable, Codable {
    let id: UUID
    var name: String
    var order: Int
    let isDefault: Bool

    init(name: String, order: Int, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.isDefault = isDefault
    }
}
```

- `isDefault` が `true` のフォルダは削除不可（UI上、削除メニューを出さない）
- フォルダ名は 1〜20文字（空文字不可）。バリデーションは `VideoListViewModel` 側で行う
- フォルダ数の上限は設けない（タブバーは横スクロールで対応する）

### VideoItem（更新）

```swift
struct VideoItem: Identifiable, Codable {
    let id: UUID
    var url: String
    var order: Int
    let createdAt: Date
    var title: String?
    var thumbnailData: Data?
    var folderId: UUID?  // 追加：nil は移行前データ。VideoListViewModel 初期化時にデフォルトフォルダへ割り当てる

    init(url: String, order: Int, folderId: UUID) {
        self.id = UUID()
        self.url = url
        self.order = order
        self.createdAt = Date()
        self.folderId = folderId
    }
}
```

- `folderId` は Codable 上は Optional にして既存 JSON（キーなし）との後方互換を保つ。新規作成時は `init` で必ず値を渡すため実質必須
- `order` は引き続きアプリ全体で一意の表示順を表す。フォルダ単位の並び替えは、フィルタ後の並び替え結果を元の配列にマージすることで実現する（後述）

## 新規コンポーネント

### `VideoFolderRepository`（Services/VideoFolderRepository.swift）

```swift
final class VideoFolderRepository {
    private let key = "videoFolders"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [VideoFolder] {
        guard let data = defaults.data(forKey: key),
              let folders = try? JSONDecoder().decode([VideoFolder].self, from: data),
              !folders.isEmpty else {
            let defaultFolder = VideoFolder(name: "デフォルト", order: 0, isDefault: true)
            save([defaultFolder])
            return [defaultFolder]
        }
        return folders.sorted { $0.order < $1.order }
    }

    func save(_ folders: [VideoFolder]) {
        guard let data = try? JSONEncoder().encode(folders) else { return }
        defaults.set(data, forKey: key)
    }
}
```

- 保存データが存在しない場合（アプリ初回起動時）と、空配列の場合の両方で「デフォルト」フォルダを自動生成する
- これにより「フォルダが1つもない状態」は発生しない

### `FolderTabBarView`（Views/FolderTabBarView.swift）

```
┌──────────────────────────────────────┐
│ [すべて] [デフォルト] [胸トレ] [背中] [＋]│  ← 横スクロール
└──────────────────────────────────────┘
```

- 先頭に固定の「すべて」タブ（`selectedFolderId == nil` に対応）
- 続けて `viewModel.folders`（`order` 順）
- 末尾に「＋」ボタン（フォルダ追加）
- 選択中タブは背景色で強調表示
- 「すべて」以外のフォルダタブは長押しでコンテキストメニュー（「名前を変更」「削除」）を表示。ただし `isDefault == true` のフォルダには「削除」を出さない
- 「削除」選択時は確認アラートを表示：「"（フォルダ名）"を削除しますか？フォルダ内の動画もすべて削除されます」

## VideoListViewModel の変更

```swift
@Observable
final class VideoListViewModel {
    var folders: [VideoFolder] = []
    var videoItems: [VideoItem] = []
    var selectedFolderId: UUID? = nil  // nil = 「すべて」タブ
    var isShowingAddVideo = false
    var isShowingAddFolder = false
    var isShowingSettings = false
    var addVideoErrorMessage: String? = nil
    var addFolderErrorMessage: String? = nil
    var videoOpenedAt: Date? = nil

    private let repository: VideoRepository
    private let folderRepository: VideoFolderRepository
    private let validator = URLValidator.self

    init(repository: VideoRepository = VideoRepository(),
         folderRepository: VideoFolderRepository = VideoFolderRepository()) {
        self.repository = repository
        self.folderRepository = folderRepository
        self.folders = folderRepository.load()
        self.videoItems = repository.load()
        migrateLegacyVideosIfNeeded()
    }

    private func migrateLegacyVideosIfNeeded() {
        guard let defaultFolder = folders.first(where: { $0.isDefault }) else { return }
        var didMigrate = false
        for index in videoItems.indices where videoItems[index].folderId == nil {
            videoItems[index].folderId = defaultFolder.id
            didMigrate = true
        }
        if didMigrate { repository.save(videoItems) }
    }

    var displayedVideoItems: [VideoItem] {
        guard let selectedFolderId else { return videoItems }
        return videoItems.filter { $0.folderId == selectedFolderId }
    }

    func isAtLimit(for folderId: UUID) -> Bool {
        videoItems.filter { $0.folderId == folderId }.count >= 10
    }

    // FAB無効化：特定フォルダタブ選択中かつそのフォルダが上限の場合のみ無効
    var isAddDisabled: Bool {
        guard let selectedFolderId else { return false }
        return isAtLimit(for: selectedFolderId)
    }

    func addVideo(url: String, folderId: UUID) async {
        guard !isAtLimit(for: folderId) else {
            addVideoErrorMessage = "選択したフォルダは動画が最大10件登録されています"
            return
        }
        guard validator.isValid(url) else {
            addVideoErrorMessage = "Instagram または YouTube の URL を入力してください"
            return
        }
        addVideoErrorMessage = nil
        let newItem = VideoItem(url: url, order: videoItems.count, folderId: folderId)
        videoItems.append(newItem)
        save()
        isShowingAddVideo = false

        let fetcher = VideoMetadataFetcher()
        if let metadata = await fetcher.fetch(urlString: url),
           let index = videoItems.firstIndex(where: { $0.id == newItem.id }) {
            videoItems[index].title = metadata.title
            videoItems[index].thumbnailData = metadata.thumbnailData
            save()
        }
    }

    func deleteVideo(at offsets: IndexSet) {
        let idsToDelete = Set(offsets.map { displayedVideoItems[$0].id })
        videoItems.removeAll { idsToDelete.contains($0.id) }
        reorder()
        save()
    }

    func moveVideo(from source: IndexSet, to destination: Int) {
        var reordered = displayedVideoItems
        reordered.move(fromOffsets: source, toOffset: destination)
        let filteredIds = Set(displayedVideoItems.map(\.id))
        var queue = reordered.makeIterator()
        videoItems = videoItems.map { filteredIds.contains($0.id) ? queue.next()! : $0 }
        reorder()
        save()
    }

    // フォルダ管理
    func addFolder(name: String) {
        guard let trimmed = validatedFolderName(name) else { return }
        let newFolder = VideoFolder(name: trimmed, order: folders.count)
        folders.append(newFolder)
        folderRepository.save(folders)
        isShowingAddFolder = false
    }

    func renameFolder(_ folder: VideoFolder, to newName: String) {
        guard let trimmed = validatedFolderName(newName),
              let index = folders.firstIndex(where: { $0.id == folder.id }) else { return }
        folders[index].name = trimmed
        folderRepository.save(folders)
    }

    func deleteFolder(_ folder: VideoFolder) {
        guard !folder.isDefault else { return }
        videoItems.removeAll { $0.folderId == folder.id }
        folders.removeAll { $0.id == folder.id }
        if selectedFolderId == folder.id { selectedFolderId = nil }
        repository.save(videoItems)
        folderRepository.save(folders)
    }

    private func validatedFolderName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            addFolderErrorMessage = "フォルダ名を入力してください"
            return nil
        }
        guard trimmed.count <= 20 else {
            addFolderErrorMessage = "フォルダ名は20文字以内で入力してください"
            return nil
        }
        addFolderErrorMessage = nil
        return trimmed
    }

    private func reorder() {
        for index in videoItems.indices {
            videoItems[index].order = index
        }
    }

    private func save() {
        repository.save(videoItems)
    }
}
```

- `moveVideo` は表示中（フィルタ後）の並び替え結果を、元の `videoItems` 配列に「フィルタ対象の要素だけ差し替える」形でマージする。これにより他フォルダの動画の相対位置を崩さずに、フォルダ単位の並び替えを実現する
- `reorder()` は従来通りグローバルな `order` を振り直す（マージ後の配列順がそのまま新しい表示順になる）

## VideoListView の変更

- `List` の上に `FolderTabBarView(viewModel: viewModel)` を追加
- `viewModel.videoItems` の参照箇所を `viewModel.displayedVideoItems` に変更
- FAB の `disabled` / グレー表示条件を `viewModel.isAtLimit` → `viewModel.isAddDisabled` に変更
- 上限メッセージ（「動画は最大10件まで登録できます」）は `viewModel.isAddDisabled` のときのみ表示
- 空表示（`ContentUnavailableView`）は `displayedVideoItems.isEmpty` を条件にする（フォルダを切り替えて中身が空の場合にも表示される）

## AddVideoView の変更

- 追加先フォルダを選択する `Picker`（メニュー形式）を `Form` 内に追加
- 初期選択値：`viewModel.selectedFolderId` が特定フォルダを指していればそれを、`nil`（すべてタブ）の場合はデフォルトフォルダを初期値にする
- 保存時：`Task { await viewModel.addVideo(url: urlText, folderId: selectedFolderId) }`

```swift
@State private var selectedFolderId: UUID

init(viewModel: VideoListViewModel) {
    self.viewModel = viewModel
    let initialFolderId = viewModel.selectedFolderId
        ?? viewModel.folders.first(where: { $0.isDefault })?.id
        ?? viewModel.folders[0].id
    _selectedFolderId = State(initialValue: initialFolderId)
}
```

## 影響範囲

- `VideoItem` の `Codable` 構造変更（`folderId` 追加）により、既存の `UserDefaults` データは `folderId: nil` として読み込まれる（後方互換あり）。`VideoListViewModel.init` 時にデフォルトフォルダへ自動移行し、即座に保存し直す
- `VideoRepositoryTests` の後方互換テスト（`test_load_legacyDataWithoutMetadata_returnsItemsWithNilFields`）と同様の観点で、`folderId` なしデータの移行テストを追加する
- `VideoListViewModel.addVideo` のシグネチャ変更（`folderId` 引数追加）により、呼び出し元 `AddVideoView` の変更が必須
- `deleteVideo` / `moveVideo` の対象がフィルタ後の配列基準に変わるため、既存のテスト（もしあれば）は表示中フォルダを踏まえたテストに更新が必要
