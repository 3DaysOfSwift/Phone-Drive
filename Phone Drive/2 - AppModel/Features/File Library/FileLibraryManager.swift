import Foundation
import Observation

@MainActor
@Observable
final class FileLibraryManager: FileLibraryFeature {
    private let repository: any DriveFilesRepository

    private(set) var files: [DriveFile] = []
    private(set) var isRefreshingFiles = false
    private(set) var fileOperationError: (any Error)?

    init(repository: any DriveFilesRepository) {
        self.repository = repository
    }

    func refreshFiles() async {
        guard !isRefreshingFiles else { return }
        isRefreshingFiles = true
        defer { isRefreshingFiles = false }

        do {
            files = try await repository.listFiles()
            fileOperationError = nil
        } catch {
            fileOperationError = error
        }
    }

    func importFile(from sourceURL: URL) async {
        do {
            try await repository.importFile(from: sourceURL)
            await refreshFiles()
        } catch {
            fileOperationError = error
        }
    }

    func deleteFile(_ file: DriveFile) async {
        do {
            try await repository.deleteFile(at: file.fileURL)
            await refreshFiles()
        } catch {
            fileOperationError = error
        }
    }

    func exchangeDirectoryURL() async throws -> URL {
        try await repository.exchangeDirectoryURL()
    }
}
