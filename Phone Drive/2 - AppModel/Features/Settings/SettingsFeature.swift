import Foundation

@MainActor
protocol SettingsFeature: AnyObject {
    var selectedColourTheme: AppColourTheme { get }
    func selectColourTheme(_ colourTheme: AppColourTheme)
}
