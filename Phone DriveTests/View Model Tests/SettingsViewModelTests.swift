import Testing
@testable import Phone_Drive

@MainActor
struct SettingsViewModelTests {
    @Test func selectingThemeForwardsTheChoiceToSettingsFeature() {
        let settingsFeature = SettingsFeatureSpy()
        let viewModel = SettingsViewModel(settingsFeature: settingsFeature)

        viewModel.selectColourTheme(.midnight)

        #expect(settingsFeature.selectedColourTheme == .midnight)
    }
}

@MainActor
private final class SettingsFeatureSpy: SettingsFeature {
    var selectedColourTheme: AppColourTheme = .system

    func selectColourTheme(_ colourTheme: AppColourTheme) {
        selectedColourTheme = colourTheme
    }
}
