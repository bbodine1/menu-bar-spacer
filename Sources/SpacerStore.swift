import Foundation

/// Persists spacer configurations to disk and user defaults.
public final class SpacerStore {
    private let fileURL: URL
    private let userDefaults: UserDefaults
    private let queue = DispatchQueue(label: "dev.menubarspacer.store", qos: .utility)

    private struct Payload: Codable {
        var spacers: [SpacerItem]
    }

    public init(fileURL: URL? = nil, userDefaults: UserDefaults = .standard) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser
            let folder = supportURL.appendingPathComponent("MenuBarSpacer", isDirectory: true)
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            self.fileURL = folder.appendingPathComponent("spacers.json")
        }
        self.userDefaults = userDefaults
    }

    public func load() -> [SpacerItem] {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(Payload.self, from: data) {
            return decoded.spacers.sorted { $0.order < $1.order }
        }
        return []
    }

    public func save(_ spacers: [SpacerItem]) {
        queue.sync {
            let payload = Payload(spacers: spacers.sorted { $0.order < $1.order })
            guard let data = try? JSONEncoder().encode(payload) else { return }
            try? data.write(to: self.fileURL, options: [.atomic])
        }
    }

    public func setLaunchAtLogin(enabled: Bool) {
        userDefaults.set(enabled, forKey: Keys.launchAtLogin)
    }

    public func isLaunchAtLoginEnabled() -> Bool {
        userDefaults.bool(forKey: Keys.launchAtLogin)
    }

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
    }
}
