import SwiftUI

struct GraphApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .frame(minWidth: 1200, minHeight: 800)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Swift Playgrounds Graph") {
                    // About dialog
                }
            }
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
