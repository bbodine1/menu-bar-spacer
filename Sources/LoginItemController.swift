import Foundation

#if canImport(ServiceManagement)
import ServiceManagement
#endif

public protocol LoginItemEnabling {
    func setEnabled(_ enabled: Bool)
}

/// Handles login item state for the app.
public final class LoginItemController: LoginItemEnabling {
    private let bundleIdentifier: String

    public init(bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "") {
        self.bundleIdentifier = bundleIdentifier
    }

    public func setEnabled(_ enabled: Bool) {
        #if os(macOS)
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Failed to toggle login item: \(error.localizedDescription)")
        }
        #endif
    }
}

