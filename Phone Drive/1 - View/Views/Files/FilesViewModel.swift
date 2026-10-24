import Foundation
import Observation

@MainActor
@Observable
final class FilesViewModel {
    private let fileLibraryFeature: any FileLibraryFeature
    private let localSharingFeature: any LocalSharingFeature
    private var importingFilesTask: Task<Void, Never>?
    private var startingLocalSharingTask: Task<Void, Never>?
    private var deletingFileTask: Task<Void, Never>?

    var isShowingError = false

    init(
        fileLibraryFeature: any FileLibraryFeature = AppModel.shared.fileLibraryFeature,
        localSharingFeature: any LocalSharingFeature = AppModel.shared.localSharingFeature
    ) {
        self.fileLibraryFeature = fileLibraryFeature
        self.localSharingFeature = localSharingFeature
    }

    var files: [DriveFile] { fileLibraryFeature.files }
    var isRefreshingFiles: Bool { fileLibraryFeature.isRefreshingFiles }
    var sharingURL: URL? { localSharingFeature.sharingURL }
    var isSharingFiles: Bool { localSharingFeature.isSharingFiles }
    var errorMessage: String { (fileLibraryFeature.fileOperationError ?? localSharingFeature.sharingError)?.localizedDescription ?? "Something went wrong." }

    func refreshFiles() async {
        await fileLibraryFeature.refreshFiles()
        if fileLibraryFeature.fileOperationError != nil { isShowingError = true }
    }

    func importFiles(from sourceURLs: [URL]) {
        guard importingFilesTask == nil else { return }
        importingFilesTask = Task { [weak self] in
            defer { self?.importingFilesTask = nil }
            guard let self else { return }
            for sourceURL in sourceURLs {
                await fileLibraryFeature.importFile(from: sourceURL)
            }
            if fileLibraryFeature.fileOperationError != nil { isShowingError = true }
        }
    }

    func deleteFile(_ file: DriveFile) {
        guard deletingFileTask == nil else { return }
        deletingFileTask = Task { [weak self] in
            defer { self?.deletingFileTask = nil }
            guard let self else { return }
            await fileLibraryFeature.deleteFile(file)
            if fileLibraryFeature.fileOperationError != nil { isShowingError = true }
        }
    }

    func startSharingFiles() {
        guard startingLocalSharingTask == nil else { return }
        startingLocalSharingTask = Task { [weak self] in
            defer { self?.startingLocalSharingTask = nil }
            guard let self else { return }
            await localSharingFeature.startSharingFiles()
            if localSharingFeature.sharingError != nil { isShowingError = true }
        }
    }

    func stopSharingFiles() {
        localSharingFeature.stopSharingFiles()
    }
}
