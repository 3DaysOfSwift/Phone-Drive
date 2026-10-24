import Observation

@MainActor
@Observable
final class RootTabViewModel {
    enum Tab: Hashable {
        case files
        case settings
    }

    var selectedTab: Tab = .files
}
