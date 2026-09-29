// swiftlint:disable:this file_name

import XCTest

@testable import BitwardenShared

// MARK: - ArrayTOTPHelpersTests

class ArrayTOTPHelpersTests: BitwardenTestCase {
    // MARK: Tests

    /// `updated(with:)` replaces existing items while preserving their order and ignores new items.
    func test_updated_preservesOrder() {
        let items: [VaultListItem] = [
            .fixture(cipherListView: .fixture(id: "3", name: "Zoom")),
            .fixture(cipherListView: .fixture(id: "1", name: "Amazon")),
            .fixture(cipherListView: .fixture(id: "2", name: "GitHub")),
        ]
        let updatedValues: [VaultListItem] = [
            .fixture(cipherListView: .fixture(id: "1", name: "Amazon Updated")),
            .fixture(cipherListView: .fixture(id: "4", name: "Bitwarden")),
        ]

        let result = items.updated(with: updatedValues)

        XCTAssertEqual(result.map(\.id), ["3", "1", "2"])
        XCTAssertEqual(result[1].sortValue, "Amazon Updated")
    }

    /// `updated(with:includeNewValues:)` appends new items, sorted by name, after the existing items.
    func test_updated_includeNewValues() {
        let items: [VaultListItem] = [
            .fixture(cipherListView: .fixture(id: "3", name: "Zoom")),
            .fixture(cipherListView: .fixture(id: "1", name: "Amazon")),
        ]
        let updatedValues: [VaultListItem] = [
            .fixture(cipherListView: .fixture(id: "5", name: "Slack")),
            .fixture(cipherListView: .fixture(id: "4", name: "Bitwarden")),
        ]

        let result = items.updated(with: updatedValues, includeNewValues: true)

        XCTAssertEqual(result.map(\.id), ["3", "1", "4", "5"])
    }
}
