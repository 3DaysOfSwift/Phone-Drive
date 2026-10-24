import Foundation

@MainActor
protocol LocalSharingFeature: AnyObject {
    var sharingURL: URL? { get }
    var isSharingFiles: Bool { get }
    var sharingError: (any Error)? { get }
    func startSharingFiles() async
    func stopSharingFiles()
}
