import XCTest
@testable import Snowdepth

@MainActor
final class SnowdepthTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(SnowdepthEntry(title: "Test", date: Date(), depth: "a", notes: "b"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testDeleteEntryDecreasesCount() {
        let store = Store()
        let entry = SnowdepthEntry(title: "ToDelete", date: Date(), depth: "a", notes: "b")
        store.add(entry)
        let before = store.entries.count
        store.delete(entry)
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testUpdateEntryModifiesExisting() {
        let store = Store()
        let entry = SnowdepthEntry(title: "Original", date: Date(), depth: "a", notes: "b")
        store.add(entry)
        var updated = entry
        updated.title = "Updated"
        store.update(updated)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.title, "Updated")
    }

    func testCanAddWhenUnderLimitAndFree() {
        let store = Store()
        store.entries = Array(repeating: SnowdepthEntry(title: "x", date: Date(), depth: "", notes: ""), count: Store.freeLimit - 1)
        XCTAssertTrue(store.canAdd(isPro: false))
    }

    func testCannotAddWhenAtLimitAndFree() {
        let store = Store()
        store.entries = Array(repeating: SnowdepthEntry(title: "x", date: Date(), depth: "", notes: ""), count: Store.freeLimit)
        XCTAssertFalse(store.canAdd(isPro: false))
    }

    func testCanAlwaysAddWhenPro() {
        let store = Store()
        store.entries = Array(repeating: SnowdepthEntry(title: "x", date: Date(), depth: "", notes: ""), count: Store.freeLimit + 5)
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testIsAtFreeLimit() {
        let store = Store()
        store.entries = Array(repeating: SnowdepthEntry(title: "x", date: Date(), depth: "", notes: ""), count: Store.freeLimit)
        XCTAssertTrue(store.isAtFreeLimit)
    }
}
