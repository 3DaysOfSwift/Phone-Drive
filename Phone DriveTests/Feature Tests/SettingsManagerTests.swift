import Foundation
import Testing
@testable import Phone_Drive

@MainActor
struct SettingsManagerTests {
    @Test func selectedColourThemeIsPersisted() throws {
        let suiteName = "SettingsManagerTests.\(UUID().uuidString)"
        let testUserDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { testUserDefaults.removePersistentDomain(forName: suiteName) }

        let settingsManager = SettingsManager(userDefaults: testUserDefaults)
        settingsManager.selectColourTheme(.midnight)

        let reloadedManager = SettingsManager(userDefaults: testUserDefaults)
        #expect(reloadedManager.selectedColourTheme == .midnight)
    }
}
