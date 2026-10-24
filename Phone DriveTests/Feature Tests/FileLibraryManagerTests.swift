import Foundation
import Testing
@testable import Phone_Drive

@MainActor
struct FileLibraryManagerTests {
    @Test func importingFileAddsItToTheLibrary() async throws {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporaryDirectoryURL) }

        let sourceURL = temporaryDirectoryURL.appending(path: "source.txt")
        try Data("Phone Drive".utf8).write(to: sourceURL)
        let exchangeDirectoryURL = temporaryDirectoryURL.appending(path: "Exchange")
        try FileManager.default.createDirectory(at: exchangeDirectoryURL, withIntermediateDirectories: true)

        let fileLibraryManager = FileLibraryManager(
            repository: try DocumentsDriveFilesRepository(documentsDirectoryURL: exchangeDirectoryURL)
        )
        await fileLibraryManager.importFile(from: sourceURL)

        #expect(fileLibraryManager.files.map(\.fileName) == ["source.txt"])
    }
}
