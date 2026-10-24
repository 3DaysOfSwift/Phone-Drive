import SwiftUI
import UniformTypeIdentifiers

struct FilesView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = FilesViewModel()
    @State private var isShowingFileImporter = false

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            List {
                Section {
                    Text("Plug your iPhone into a Mac, open Finder, select this iPhone, then open Files to drag files into Phone Drive.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } header: {
                    Label("USB file sharing", systemImage: "cable.connector")
                }

                Section {
                    if let sharingURL = viewModel.sharingURL {
                        ShareLink(item: sharingURL) {
                            Label(sharingURL.absoluteString, systemImage: "link")
                                .textSelection(.enabled)
                        }
                        Text("Anyone on this Wi-Fi network with this address can download the files shown below. Sharing stops when you tap Stop Sharing or close the app.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Stop Sharing", role: .destructive, action: viewModel.stopSharingFiles)
                    } else {
                        Button {
                            viewModel.startSharingFiles()
                        } label: {
                            Label("Start local sharing", systemImage: "wifi")
                        }
                        Text("Creates a private, read-only web address for computers on the same Wi-Fi network.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Local web address", systemImage: "network")
                }

                Section("Files") {
                    if viewModel.files.isEmpty {
                        ContentUnavailableView("No files yet", systemImage: "folder", description: Text("Drag a file into Finder, or import one from this iPhone."))
                    } else {
                        ForEach(viewModel.files) { file in
                            HStack {
                                Image(systemName: iconName(for: file.fileURL.pathExtension))
                                    .foregroundStyle(themeManager.selectedTheme.accentColour)
                                VStack(alignment: .leading) {
                                    Text(file.fileName)
                                        .lineLimit(1)
                                    Text("\(file.fileSize, format: .byteCount(style: .file)) · \(file.modifiedDate, format: .dateTime.month().day().hour().minute())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityLabel("\(file.fileName), \(file.fileSize.formatted(.byteCount(style: .file)))")
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteFile(file)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Phone Drive")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingFileImporter = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.data], allowsMultipleSelection: true) { result in
                if case let .success(sourceURLs) = result {
                    viewModel.importFiles(from: sourceURLs)
                }
            }
            .refreshable { await viewModel.refreshFiles() }
            .alert("Phone Drive", isPresented: $viewModel.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    private func iconName(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf": "doc.richtext"
        case "jpg", "jpeg", "png", "heic": "photo"
        case "mp4", "mov": "video"
        default: "doc"
        }
    }
}
