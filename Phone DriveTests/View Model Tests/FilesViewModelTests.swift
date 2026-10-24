import Foundation
import Testing
@testable import Phone_Drive

@MainActor
struct FilesViewModelTests {
    @Test func filesAreExposedFromTheFileLibraryFeature() async {
        let fileURL = URL(fileURLWithPath: "/tmp/example.pdf")
        let fileLibraryFeature = FileLibraryFeatureSpy(files: [DriveFile(fileURL: fileURL, fileSize: 42, modifiedDate: .distantPast)])
        let viewModel = FilesViewModel(fileLibraryFeature: fileLibraryFeature, localSharingFeature: LocalSharingFeatureSpy())

        #expect(viewModel.files.map(\.fileName) == ["example.pdf"])
    }
}

@MainActor
private final class FileLibraryFeatureSpy: FileLibraryFeature {
    var files: [DriveFile]
    var isRefreshingFiles = false
    var fileOperationError: (any Error)?

    init(files: [DriveFile]) { self.files = files }
    func refreshFiles() async {}
    func importFile(from: URL) async {}
    func deleteFile(_: DriveFile) async {}
    func exchangeDirectoryURL() async throws -> URL { URL(fileURLWithPath: "/tmp") }
}

@MainActor
private final class LocalSharingFeatureSpy: LocalSharingFeature {
    var sharingURL: URL?
    var isSharingFiles = false
    var sharingError: (any Error)?
    func startSharingFiles() async {}
    func stopSharingFiles() {}
}
