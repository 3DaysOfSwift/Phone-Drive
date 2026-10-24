import Foundation

protocol DriveFilesRepository: Sendable {
    func listFiles() async throws -> [DriveFile]
    func importFile(from sourceURL: URL) async throws
    func deleteFile(at fileURL: URL) async throws
    func exchangeDirectoryURL() async throws -> URL
}
