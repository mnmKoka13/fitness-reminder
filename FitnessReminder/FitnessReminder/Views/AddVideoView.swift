import SwiftUI

struct AddVideoView: View {
    @Bindable var viewModel: VideoListViewModel
    @State private var urlText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URLを貼り付け", text: $urlText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                } footer: {
                    if let error = viewModel.addVideoErrorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                    } else {
                        Text("Instagram または YouTube の URL を入力してください")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("動画を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        viewModel.addVideoErrorMessage = nil
                        viewModel.isShowingAddVideo = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        viewModel.addVideo(url: urlText)
                    }
                    .disabled(urlText.isEmpty)
                }
            }
        }
    }
}
