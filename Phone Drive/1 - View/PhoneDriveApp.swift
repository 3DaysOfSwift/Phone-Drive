import SwiftUI
import UIKit

final class PhoneDriveAppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Task { @MainActor in
            await AppModel.shared.applicationDidFinishLaunching()
        }
        return true
    }
}

@main
struct PhoneDriveApp: App {
    @UIApplicationDelegateAdaptor(PhoneDriveAppDelegate.self) private var appDelegate
    @State private var themeManager: ThemeManager

    init() {
        _themeManager = State(
            initialValue: ThemeManager(
                selectedTheme: AppModel.shared.settingsFeature.selectedColourTheme
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
                .onOpenURL { sourceURL in
                    AppModel.shared.importIncomingFile(from: sourceURL)
                }
        }
    }
}
