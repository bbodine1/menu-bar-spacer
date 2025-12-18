import XCTest
@testable import MenuBarSpacer

final class MockLoginItemController: LoginItemEnabling {
    private(set) var enabledStates: [Bool] = []
    func setEnabled(_ enabled: Bool) {
        enabledStates.append(enabled)
    }
}

final class SpacerManagerViewModelTests: XCTestCase {
    func testAddsSpacerAndPersistsOrder() {
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: .init(suiteName: UUID().uuidString)!)
        let login = MockLoginItemController()
        let viewModel = SpacerManagerViewModel(spacers: [], spacerStore: store, loginController: login)
        viewModel.addSpacer()
        viewModel.addSpacer()
        XCTAssertEqual(viewModel.spacers.count, 2)
        XCTAssertEqual(viewModel.spacers[0].order, 0)
        XCTAssertEqual(viewModel.spacers[1].order, 1)
    }

    func testUpdatesWidth() {
        let spacer = SpacerItem(width: 24, order: 0)
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: .init(suiteName: UUID().uuidString)!)
        let viewModel = SpacerManagerViewModel(spacers: [spacer], spacerStore: store, loginController: MockLoginItemController())
        viewModel.updateWidth(for: spacer.id, width: 75)
        XCTAssertEqual(viewModel.spacers.first?.width, 75)
    }

    func testDeleteSpacerAndReorders() {
        let spacerA = SpacerItem(width: 24, order: 0)
        let spacerB = SpacerItem(width: 30, order: 1)
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: .init(suiteName: UUID().uuidString)!)
        let viewModel = SpacerManagerViewModel(spacers: [spacerA, spacerB], spacerStore: store, loginController: MockLoginItemController())
        viewModel.deleteSpacer(at: IndexSet(integer: 0))
        XCTAssertEqual(viewModel.spacers.count, 1)
        XCTAssertEqual(viewModel.spacers.first?.order, 0)
    }

    func testDeleteSelectedSpacerUpdatesSelection() {
        let spacerA = SpacerItem(width: 24, order: 0)
        let spacerB = SpacerItem(width: 30, order: 1)
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: .init(suiteName: UUID().uuidString)!)
        let viewModel = SpacerManagerViewModel(spacers: [spacerA, spacerB], spacerStore: store, loginController: MockLoginItemController())
        viewModel.selectedSpacerID = spacerB.id
        viewModel.deleteSelectedSpacer()
        XCTAssertEqual(viewModel.spacers.count, 1)
        XCTAssertEqual(viewModel.selectedSpacerID, spacerA.id)
    }

    func testMoveSpacerUpdatesOrder() {
        let spacerA = SpacerItem(width: 24, order: 0)
        let spacerB = SpacerItem(width: 30, order: 1)
        let spacerC = SpacerItem(width: 40, order: 2)
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: .init(suiteName: UUID().uuidString)!)
        let viewModel = SpacerManagerViewModel(spacers: [spacerA, spacerB, spacerC], spacerStore: store, loginController: MockLoginItemController())
        viewModel.moveSpacer(from: IndexSet(integer: 0), to: 3)
        XCTAssertEqual(viewModel.spacers[2].id, spacerA.id)
        XCTAssertEqual(viewModel.spacers[2].order, 2)
    }

    func testLaunchAtLoginToggleSavesPreference() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: defaults)
        let mockLogin = MockLoginItemController()
        let viewModel = SpacerManagerViewModel(spacers: [], spacerStore: store, loginController: mockLogin)
        viewModel.launchAtLogin = true
        XCTAssertTrue(defaults.bool(forKey: "launchAtLogin"))
        XCTAssertEqual(mockLogin.enabledStates.last, true)
    }
}
