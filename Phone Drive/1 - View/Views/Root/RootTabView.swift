import SwiftUI

struct RootTabView: View {
    @State private var viewModel = RootTabViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            FilesView()
                .tabItem { Label("Files", systemImage: "externaldrive") }
                .tag(RootTabViewModel.Tab.files)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(RootTabViewModel.Tab.settings)
        }
    }
}
