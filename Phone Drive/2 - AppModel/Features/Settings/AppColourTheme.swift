enum AppColourTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case midnight

    var id: String { rawValue }
    var displayName: String { self == .system ? "System" : "Midnight" }
}
