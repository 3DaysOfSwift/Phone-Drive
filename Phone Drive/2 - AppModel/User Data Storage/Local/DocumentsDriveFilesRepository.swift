import Foundation

actor DocumentsDriveFilesRepository: DriveFilesRepository {
    private let documentsDirectoryURL: URL

    init(documentsDirectoryURL: URL? = nil) throws {
        self.documentsDirectoryURL = try documentsDirectoryURL ?? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    func listFiles() throws -> [DriveFile] {
        let fileManager = FileManager.default
        let fileURLs = try fileManager.contentsOfDirectory(
            at: documentsDirectoryURL,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        return try fileURLs.compactMap { fileURL in
            let values = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey])
            guard values.isRegularFile == true else { return nil }
            return DriveFile(
                fileURL: fileURL,
                fileSize: Int64(values.fileSize ?? 0),
                modifiedDate: values.contentModificationDate ?? .distantPast
            )
        }
        .sorted { $0.modifiedDate > $1.modifiedDate }
    }

    func importFile(from sourceURL: URL) throws {
        let fileManager = FileManager.default
        let didGainAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didGainAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let destinationURL = uniqueDestinationURL(for: sourceURL.lastPathComponent)
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }

    func deleteFile(at fileURL: URL) throws {
        let fileManager = FileManager.default
        guard fileURL.deletingLastPathComponent() == documentsDirectoryURL else {
            throw DriveFilesRepositoryError.invalidFileLocation
        }
        try fileManager.removeItem(at: fileURL)
    }

    func exchangeDirectoryURL() -> URL {
        documentsDirectoryURL
    }

    private func uniqueDestinationURL(for fileName: String) -> URL {
        let fileManager = FileManager.default
        let proposedURL = documentsDirectoryURL.appending(path: fileName)
        guard fileManager.fileExists(atPath: proposedURL.path) else { return proposedURL }

        let baseName = proposedURL.deletingPathExtension().lastPathComponent
        let fileExtension = proposedURL.pathExtension
        var copyNumber = 2
        while true {
            let candidateName = fileExtension.isEmpty
                ? "\(baseName) \(copyNumber)"
                : "\(baseName) \(copyNumber).\(fileExtension)"
            let candidateURL = documentsDirectoryURL.appending(path: candidateName)
            guard !fileManager.fileExists(atPath: candidateURL.path) else {
                copyNumber += 1
                continue
            }
            return candidateURL
        }
    }
}

enum DriveFilesRepositoryError: LocalizedError {
    case invalidFileLocation

    var errorDescription: String? {
        "Phone Drive can only remove files in its exchange folder."
    }
}
