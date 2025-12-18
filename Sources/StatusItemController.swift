import Foundation
#if canImport(AppKit)
import AppKit
import SwiftUI

/// Manages creation and updates of spacer status items.
public final class StatusItemController: ObservableObject {
    private let statusBar: NSStatusBar
    private let spacerStore: SpacerStore
    private let loginController: LoginItemEnabling
    private var spacerItems: [UUID: NSStatusItem] = [:]
    private var popover: NSPopover?
    private var managerViewModel: SpacerManagerViewModel
    private var mainStatusItem: NSStatusItem?

    public init(statusBar: NSStatusBar = .system,
                spacerStore: SpacerStore,
                loginController: LoginItemEnabling) {
        self.statusBar = statusBar
        self.spacerStore = spacerStore
        self.loginController = loginController
        let spacers = spacerStore.load()
        self.managerViewModel = SpacerManagerViewModel(
            spacers: spacers,
            spacerStore: spacerStore,
            loginController: loginController
        )
        rebuildSpacerItems(with: spacers)
        createMainStatusItem()
        updateMainStatusItemVisibility()
    }

    // MARK: - Status item creation

    private func createMainStatusItem() {
        let item = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "▣"
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Manage Spacers…", action: #selector(togglePopover(_:)), keyEquivalent: ""))
        menu.items.last?.target = self
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createPlaceholderMenuItemIfNeeded())
        item.menu = menu
        mainStatusItem = item
    }

    private func createPlaceholderMenuItemIfNeeded() -> NSMenuItem {
        if managerViewModel.spacers.isEmpty {
            let placeholder = NSMenuItem(title: "Add spacer", action: #selector(addSpacerFromMenu), keyEquivalent: "")
            placeholder.target = self
            return placeholder
        }
        let manage = NSMenuItem(title: "New spacer", action: #selector(addSpacerFromMenu), keyEquivalent: "")
        manage.target = self
        return manage
    }

    private func rebuildSpacerItems(with spacers: [SpacerItem]) {
        spacerItems.values.forEach { statusBar.removeStatusItem($0) }
        spacerItems = [:]
        for spacer in spacers.sorted(by: { $0.order < $1.order }) {
            let spacerID = spacer.id
            let statusItem = statusBar.statusItem(withLength: CGFloat(spacer.width))
            statusItem.length = CGFloat(spacer.width)
            statusItem.isVisible = true
            let spacerView = SpacerStatusItemView(width: spacer.width)
            spacerView.onClick = { [weak self, weak statusItem] in
                self?.managerViewModel.selectedSpacerID = spacerID
                self?.togglePopover(anchor: statusItem?.view)
            }
            statusItem.view = spacerView
            spacerView.updateWidth(spacer.width)
            spacerItems[spacer.id] = statusItem
        }
    }

    // MARK: - Popover

    @objc private func togglePopover(_ sender: Any?) {
        togglePopover(anchor: (sender as? NSView) ?? mainStatusItem?.button)
    }

    private func togglePopover(anchor: NSView?) {
        if popover?.isShown == true {
            popover?.performClose(anchor)
        }
        guard let anchor else { return }
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 400)
        let view = SpacerManagerView(viewModel: managerViewModel) { [weak self] spacers in
            self?.rebuildSpacerItems(with: spacers)
            self?.refreshMenuPlaceholder()
            self?.updateMainStatusItemVisibility()
        }
        popover.contentViewController = NSHostingController(rootView: view)
        popover.show(relativeTo: anchor.bounds, of: anchor, preferredEdge: .minY)
        self.popover = popover
    }

    // MARK: - Actions

    @objc private func addSpacerFromMenu() {
        managerViewModel.addSpacer()
        rebuildSpacerItems(with: managerViewModel.spacers)
        refreshMenuPlaceholder()
        updateMainStatusItemVisibility()
    }

    private func refreshMenuPlaceholder() {
        mainStatusItem?.menu = {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Manage Spacers…", action: #selector(togglePopover(_:)), keyEquivalent: ""))
            menu.items.last?.target = self
            menu.addItem(NSMenuItem.separator())
            menu.addItem(createPlaceholderMenuItemIfNeeded())
            return menu
        }()
    }

    private func updateMainStatusItemVisibility() {
        mainStatusItem?.isVisible = managerViewModel.spacers.isEmpty
    }
}
#endif

