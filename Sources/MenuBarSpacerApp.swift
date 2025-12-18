#if os(macOS)
import SwiftUI
import AppKit

@main
struct MenuBarSpacerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = SpacerStore()
        let loginController = LoginItemController()
        statusItemController = StatusItemController(spacerStore: store, loginController: loginController)
    }
}
#endif
