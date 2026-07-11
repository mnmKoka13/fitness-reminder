import SwiftUI

struct VideoListView: View {
    @Environment(\.openURL) private var openURL
    @Bindable var viewModel: VideoListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FolderTabBarView(viewModel: viewModel)

                ZStack(alignment: .bottomTrailing) {
                    if viewModel.displayedVideoItems.isEmpty {
                        ContentUnavailableView(
                            "動画が登録されていません",
                            systemImage: "play.rectangle",
                            description: Text("＋ボタンから動画を追加してください")
                        )
                    } else {
                        List {
                            ForEach(viewModel.displayedVideoItems) { item in
                                Button {
                                    if let url = URL(string: item.url) {
                                        viewModel.videoOpenedAt = Date()
                                        openURL(url)
                                    }
                                } label: {
                                    VideoRowView(item: item)
                                }
                                .foregroundStyle(.primary)
                            }
                            .onDelete(perform: viewModel.deleteVideo)
                            .onMove(perform: viewModel.moveVideo)
                            if viewModel.isAddDisabled {
                                Text("動画は最大10件まで登録できます")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }

                    Button {
                        viewModel.isShowingAddVideo = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(viewModel.isAddDisabled ? Color.gray : Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .disabled(viewModel.isAddDisabled)
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("お気に入り動画一覧")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.displayedVideoItems.isEmpty {
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
                #endif
            }
            .sheet(isPresented: $viewModel.isShowingAddVideo) {
                AddVideoView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingSettings) {
                SettingsView()
            }
        }
    }
}
