import SwiftUI

extension AppColourTheme {
    var accentColour: Color { .blue }
    var screenBackground: Color { self == .midnight ? Color(red: 0.06, green: 0.07, blue: 0.09) : Color(uiColor: .systemGroupedBackground) }
}
