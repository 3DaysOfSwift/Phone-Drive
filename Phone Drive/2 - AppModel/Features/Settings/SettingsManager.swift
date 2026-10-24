import Foundation
import Observation

@MainActor
@Observable
final class SettingsManager: SettingsFeature {
    private let selectedColourThemeStorageKey = "selectedColourTheme"
    private let userDefaults: UserDefaults

    private(set) var selectedColourTheme: AppColourTheme

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        selectedColourTheme = AppColourTheme(rawValue: userDefaults.string(forKey: selectedColourThemeStorageKey) ?? "") ?? .system
    }

    func selectColourTheme(_ colourTheme: AppColourTheme) {
        selectedColourTheme = colourTheme
        userDefaults.set(colourTheme.rawValue, forKey: selectedColourThemeStorageKey)
    }
}
