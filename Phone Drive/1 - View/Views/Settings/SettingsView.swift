import SwiftUI

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Colour theme", selection: Binding(
                    get: { viewModel.selectedColourTheme },
                    set: { colourTheme in
                        viewModel.selectColourTheme(colourTheme)
                        themeManager.selectedTheme = colourTheme
                    }
                )) {
                    ForEach(AppColourTheme.allCases) { colourTheme in
                        Text(colourTheme.displayName).tag(colourTheme)
                    }
                }
            }

            Section("How it works") {
                Text("Phone Drive uses the app’s Documents folder as its exchange folder. Finder File Sharing and files opened with Phone Drive are copied there.")
                Text("Local sharing is off by default and only makes files available to devices on the same Wi-Fi network while it is running.")
            }

            Section {
                LabeledContent("App") {
                    Text(viewModel.appName)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Storage", value: "Documents folder · on device")
                LabeledContent("Architecture") {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("CFA iOS Architecture")
                        Text("Built with Cooperative Feature Architecture.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("About")
            } footer: {
                VStack(spacing: 20) {
                    Text("Keep files handy and share them safely from your iPhone.")
                    Text(viewModel.versionDescription)
                }
                .font(.footnote)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Settings")
    }
}
