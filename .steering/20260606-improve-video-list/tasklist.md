# 動画リスト機能改善 タスクリスト

## 進捗状況

凡例：`[ ]` 未着手 / `[x]` 完了

---

## Phase 1: データモデル更新

- [ ] 1-1. `VideoItem` に `title: String?` と `thumbnailData: Data?` を追加する

## Phase 2: サービス層追加

- [ ] 2-1. `VideoMetadataFetcher.swift` を新規作成する（YouTube oEmbed・Instagram OGP取得）
- [ ] 2-2. YouTube oEmbed API でタイトル・サムネイルを取得する処理を実装する
- [ ] 2-3. Instagram HTML から OGP タグを解析する処理を実装する

## Phase 3: ViewModel更新

- [ ] 3-1. `VideoListViewModel.addVideo` を `async` に変更する
- [ ] 3-2. 上限チェック（10件）を追加する（`isAtLimit` プロパティ）
- [ ] 3-3. メタデータ取得後に `videoItems` を更新・保存する処理を追加する

## Phase 4: View更新

- [ ] 4-1. `VideoRowView.swift` を新規作成する（サムネイル + タイトル表示）
- [ ] 4-2. `VideoListView` に上限メッセージと FAB 無効化を追加する
- [ ] 4-3. `AddVideoView` の `addVideo` 呼び出しを `Task { }` で非同期化する

## Phase 5: 動作確認

- [ ] 5-1. YouTube URL を登録してタイトル・サムネイルが表示されることを確認する
- [ ] 5-2. Instagram URL を登録して表示されることを確認する（代替表示も確認）
- [ ] 5-3. 10件登録後に FAB が無効化され上限メッセージが表示されることを確認する
- [ ] 5-4. アプリ再起動後もサムネイル・タイトルが保持されていることを確認する

## 完了条件

`requirements.md` の受け入れ条件がすべてチェックされた状態。
