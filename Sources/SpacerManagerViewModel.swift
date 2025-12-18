import Foundation
import Combine
import CoreGraphics

/// Acts as the single source of truth for the popover UI and status item sync.
public final class SpacerManagerViewModel: ObservableObject {
    @Published public private(set) var spacers: [SpacerItem]
    @Published public var selectedSpacerID: SpacerItem.ID?
    @Published public var launchAtLogin: Bool

    private let spacerStore: SpacerStore
    private let loginController: LoginItemEnabling
    private var cancellables: Set<AnyCancellable> = []

    public init(spacers: [SpacerItem], spacerStore: SpacerStore, loginController: LoginItemEnabling) {
        self.spacers = spacers.sorted { $0.order < $1.order }
        self.spacerStore = spacerStore
        self.loginController = loginController
        self.launchAtLogin = spacerStore.isLaunchAtLoginEnabled()
        bindPersistence()
    }

    private func bindPersistence() {
        $spacers
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .sink { [weak self] spacers in
                self?.spacerStore.save(spacers)
            }
            .store(in: &cancellables)

        $launchAtLogin
            .dropFirst()
            .sink { [weak self] enabled in
                self?.spacerStore.setLaunchAtLogin(enabled: enabled)
                self?.loginController.setEnabled(enabled)
            }
            .store(in: &cancellables)
    }

    public func addSpacer() {
        let nextOrder = (spacers.map { $0.order }.max() ?? -1) + 1
        let spacer = SpacerItem(width: 32, order: nextOrder)
        spacers.append(spacer)
        selectedSpacerID = spacer.id
    }

    public func deleteSpacer(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            spacers.remove(at: index)
        }
        resequenceOrders()
    }

    public func updateWidth(for spacerID: SpacerItem.ID, width: CGFloat) {
        guard let index = spacers.firstIndex(where: { $0.id == spacerID }) else { return }
        spacers[index].width = width
    }

    public func moveSpacer(from source: IndexSet, to destination: Int) {
        let moving = source.map { spacers[$0] }
        for index in source.sorted(by: >) {
            spacers.remove(at: index)
        }
        spacers.insert(contentsOf: moving, at: destination)
        resequenceOrders()
    }

    private func resequenceOrders() {
        for (idx, item) in spacers.enumerated() {
            spacers[idx].order = idx
        }
    }
}
