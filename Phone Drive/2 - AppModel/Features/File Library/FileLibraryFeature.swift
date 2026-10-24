import Foundation

@MainActor
protocol FileLibraryFeature: AnyObject {
    var files: [DriveFile] { get }
    var isRefreshingFiles: Bool { get }
    var fileOperationError: (any Error)? { get }
    func refreshFiles() async
    func importFile(from sourceURL: URL) async
    func deleteFile(_ file: DriveFile) async
    func exchangeDirectoryURL() async throws -> URL
}
