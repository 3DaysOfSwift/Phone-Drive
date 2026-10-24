import SwiftUI
import Observation

@MainActor
@Observable
final class ThemeManager {
    var selectedTheme: AppColourTheme

    init(selectedTheme: AppColourTheme) {
        self.selectedTheme = selectedTheme
    }

    var preferredColorScheme: ColorScheme? {
        selectedTheme == .midnight ? .dark : nil
    }
}
