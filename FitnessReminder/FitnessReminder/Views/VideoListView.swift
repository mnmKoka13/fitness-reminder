import SwiftUI

struct VideoListView: View {
    @Environment(\.openURL) private var openURL
    @Bindable var viewModel: VideoListViewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if viewModel.videoItems.isEmpty {
                    ContentUnavailableView(
                        "動画が登録されていません",
                        systemImage: "play.rectangle",
                        description: Text("＋ボタンから動画を追加してください")
                    )
                } else {
                    List {
                        ForEach(viewModel.videoItems) { item in
                            Button {
                                if let url = URL(string: item.url) {
                                    openURL(url)
                                }
                            } label: {
                                Label(item.url, systemImage: videoIcon(for: item.url))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            .foregroundStyle(.primary)
                        }
                        .onDelete(perform: viewModel.deleteVideo)
                        .onMove(perform: viewModel.moveVideo)
                    }
                }

                Button {
                    viewModel.isShowingAddVideo = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("運動リマインダー")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.videoItems.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddVideo) {
                AddVideoView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingSettings) {
                SettingsView()
            }
        }
    }

    private func videoIcon(for url: String) -> String {
        if url.contains("instagram.com") { return "camera.fill" }
        if url.contains("youtube.com") || url.contains("youtu.be") { return "play.rectangle.fill" }
        return "link"
    }
}
