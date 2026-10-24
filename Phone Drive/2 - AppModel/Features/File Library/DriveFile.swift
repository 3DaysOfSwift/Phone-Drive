import Foundation

struct DriveFile: Identifiable, Equatable, Sendable {
    let fileURL: URL
    let fileSize: Int64
    let modifiedDate: Date

    var id: URL { fileURL }
    var fileName: String { fileURL.lastPathComponent }
}
