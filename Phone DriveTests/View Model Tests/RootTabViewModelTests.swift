import Testing
@testable import Phone_Drive

@MainActor
struct RootTabViewModelTests {
    @Test func filesIsTheInitialTab() {
        #expect(RootTabViewModel().selectedTab == .files)
    }
}
