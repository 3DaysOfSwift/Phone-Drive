import Foundation
import Observation

@MainActor
@Observable
final class LocalSharingManager: LocalSharingFeature {
    private let fileLibraryFeature: any FileLibraryFeature
    private let webServer: LocalFileWebServer

    private(set) var sharingURL: URL?
    private(set) var isSharingFiles = false
    private(set) var sharingError: (any Error)?

    init(fileLibraryFeature: any FileLibraryFeature, webServer: LocalFileWebServer = LocalFileWebServer()) {
        self.fileLibraryFeature = fileLibraryFeature
        self.webServer = webServer
    }

    func startSharingFiles() async {
        guard !isSharingFiles else { return }
        do {
            let exchangeDirectoryURL = try await fileLibraryFeature.exchangeDirectoryURL()
            let localURL = try webServer.startServingFiles(in: exchangeDirectoryURL)
            sharingURL = localURL
            isSharingFiles = true
            sharingError = nil
        } catch {
            sharingError = error
        }
    }

    func stopSharingFiles() {
        webServer.stopServingFiles()
        sharingURL = nil
        isSharingFiles = false
    }
}
