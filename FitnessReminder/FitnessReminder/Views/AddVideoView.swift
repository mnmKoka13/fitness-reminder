import SwiftUI

struct AddVideoView: View {
    @Bindable var viewModel: VideoListViewModel
    @State private var urlText = ""
    @State private var selectedFolderId: UUID

    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        let initialFolderId = viewModel.selectedFolderId
            ?? viewModel.folders.first(where: { $0.isDefault })?.id
            ?? viewModel.folders[0].id
        _selectedFolderId = State(initialValue: initialFolderId)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URLを貼り付け", text: $urlText)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        #endif
                } footer: {
                    if let error = viewModel.addVideoErrorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    } else {
                        Text("Instagram または YouTube の URL を入力してください")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Picker("追加先フォルダ", selection: $selectedFolderId) {
                        ForEach(viewModel.folders) { folder in
                            Text(folder.name).tag(folder.id)
                        }
                    }
                }
            }
            .navigationTitle("動画を追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.addVideoErrorMessage = nil
                        viewModel.isShowingAddVideo = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await viewModel.addVideo(url: urlText, folderId: selectedFolderId) }
                    }
                    .disabled(urlText.isEmpty)
                }
            }
        }
    }
}
