import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let settingsFeature: any SettingsFeature

    init(settingsFeature: any SettingsFeature = AppModel.shared.settingsFeature) {
        self.settingsFeature = settingsFeature
    }

    var selectedColourTheme: AppColourTheme { settingsFeature.selectedColourTheme }

    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Phone Drive"
    }

    var versionDescription: String {
        let marketingVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unavailable"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unavailable"
        return "Version \(marketingVersion) (\(buildNumber))"
    }

    func selectColourTheme(_ colourTheme: AppColourTheme) {
        settingsFeature.selectColourTheme(colourTheme)
    }
}
