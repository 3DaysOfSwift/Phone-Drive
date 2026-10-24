import Foundation

@MainActor
final class AppModel {
    static let shared = AppModel.live()

    let fileLibraryFeature: any FileLibraryFeature
    let localSharingFeature: any LocalSharingFeature
    let settingsFeature: any SettingsFeature
    private var hasFinishedLaunching = false
    private var pendingIncomingFileURLs: [URL] = []
    private var importingIncomingFilesTask: Task<Void, Never>?

    init(fileLibraryFeature: any FileLibraryFeature, localSharingFeature: any LocalSharingFeature, settingsFeature: any SettingsFeature) {
        self.fileLibraryFeature = fileLibraryFeature
        self.localSharingFeature = localSharingFeature
        self.settingsFeature = settingsFeature
    }

    func applicationDidFinishLaunching() async {
        guard !hasFinishedLaunching else { return }
        hasFinishedLaunching = true
        await fileLibraryFeature.refreshFiles()
    }

    func importIncomingFile(from sourceURL: URL) {
        pendingIncomingFileURLs.append(sourceURL)
        guard importingIncomingFilesTask == nil else { return }

        importingIncomingFilesTask = Task { [weak self] in
            defer { self?.importingIncomingFilesTask = nil }
            guard let self else { return }
            while !pendingIncomingFileURLs.isEmpty {
                let nextSourceURL = pendingIncomingFileURLs.removeFirst()
                await fileLibraryFeature.importFile(from: nextSourceURL)
            }
        }
    }

    static func live() -> AppModel {
        do {
            let fileLibraryManager = FileLibraryManager(repository: try DocumentsDriveFilesRepository())
            return AppModel(
                fileLibraryFeature: fileLibraryManager,
                localSharingFeature: LocalSharingManager(fileLibraryFeature: fileLibraryManager),
                settingsFeature: SettingsManager()
            )
        } catch {
            preconditionFailure("Phone Drive could not open its exchange folder: \(error.localizedDescription)")
        }
    }
}
