import SwiftUI

struct FolderTabBarView: View {
    @Bindable var viewModel: VideoListViewModel

    @State private var newFolderName = ""
    @State private var folderToRename: VideoFolder?
    @State private var renamingFolderName = ""
    @State private var folderToDelete: VideoFolder?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tabButton(title: "すべて", isSelected: viewModel.selectedFolderId == nil) {
                    viewModel.selectedFolderId = nil
                }

                ForEach(viewModel.folders) { folder in
                    tabButton(title: folder.name, isSelected: viewModel.selectedFolderId == folder.id) {
                        viewModel.selectedFolderId = folder.id
                    }
                    .contextMenu {
                        Button {
                            folderToRename = folder
                            renamingFolderName = folder.name
                        } label: {
                            Label("名前を変更", systemImage: "pencil")
                        }
                        if !folder.isDefault {
                            Button(role: .destructive) {
                                folderToDelete = folder
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }

                Button {
                    newFolderName = ""
                    viewModel.isShowingAddFolder = true
                } label: {
                    Image(systemName: "plus")
                        .font(.subheadline.bold())
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .alert("新しいフォルダ", isPresented: $viewModel.isShowingAddFolder) {
            TextField("フォルダ名", text: $newFolderName)
            Button("キャンセル", role: .cancel) {}
            Button("追加") {
                viewModel.addFolder(name: newFolderName)
            }
        } message: {
            if let error = viewModel.addFolderErrorMessage {
                Text(error)
            }
        }
        .alert("フォルダ名を変更", isPresented: Binding(
            get: { folderToRename != nil },
            set: { if !$0 { folderToRename = nil } }
        )) {
            TextField("フォルダ名", text: $renamingFolderName)
            Button("キャンセル", role: .cancel) {}
            Button("保存") {
                if let folder = folderToRename {
                    viewModel.renameFolder(folder, to: renamingFolderName)
                }
            }
        } message: {
            if let error = viewModel.addFolderErrorMessage {
                Text(error)
            }
        }
        .alert("フォルダを削除しますか？", isPresented: Binding(
            get: { folderToDelete != nil },
            set: { if !$0 { folderToDelete = nil } }
        )) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                if let folder = folderToDelete {
                    viewModel.deleteFolder(folder)
                }
            }
        } message: {
            if let folder = folderToDelete {
                Text("\"\(folder.name)\"を削除しますか？フォルダ内の動画もすべて削除されます")
            }
        }
    }

    private func tabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
