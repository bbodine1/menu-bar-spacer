import XCTest
@testable import MenuBarSpacer
import CoreGraphics

final class SpacerStoreTests: XCTestCase {
    func testPersistsAndLoadsSpacers() throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let store = SpacerStore(fileURL: tempURL, userDefaults: .init(suiteName: UUID().uuidString)!)
        let items = [SpacerItem(width: 40, order: 0), SpacerItem(width: 80, order: 1)]
        store.save(items)

        let loaded = store.load()
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].width, 40)
        XCTAssertEqual(loaded[1].width, 80)
    }

    func testLaunchAtLoginPreferenceIsStored() throws {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        let store = SpacerStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString), userDefaults: defaults)
        XCTAssertFalse(store.isLaunchAtLoginEnabled())
        store.setLaunchAtLogin(enabled: true)
        XCTAssertTrue(store.isLaunchAtLoginEnabled())
    }
}
