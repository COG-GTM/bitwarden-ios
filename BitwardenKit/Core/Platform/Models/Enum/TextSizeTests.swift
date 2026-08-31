import BitwardenResources
import UIKit
import XCTest

@testable import BitwardenKit

class TextSizeTests: BitwardenTestCase {
    // MARK: Tests

    /// `init` returns the expected values.
    func test_init() {
        XCTAssertEqual(TextSize("large"), .large)
        XCTAssertEqual(TextSize(nil), .default)
        XCTAssertEqual(TextSize("larger"), .larger)
        XCTAssertEqual(TextSize("largest"), .largest)
        XCTAssertEqual(TextSize("gibberish"), .default)
    }

    /// `allCases` contains all text sizes in the expected order.
    func test_allCases() {
        XCTAssertEqual(TextSize.allCases, [.default, .large, .larger, .largest])
    }

    /// `contentSizeCategory` has the expected values.
    func test_contentSizeCategory() {
        XCTAssertNil(TextSize.default.contentSizeCategory)
        XCTAssertEqual(TextSize.large.contentSizeCategory, .extraLarge)
        XCTAssertEqual(TextSize.larger.contentSizeCategory, .extraExtraExtraLarge)
        XCTAssertEqual(TextSize.largest.contentSizeCategory, .accessibilityMedium)
    }

    /// `applyTextSize` applies the selected text size when it is larger than the system text size.
    @available(iOS 17.0, *)
    func test_applyTextSize_selectedTextSizeLargerThanSystem() {
        let viewController = UIViewController()

        viewController.applyTextSize(.large, systemContentSizeCategory: .large)

        XCTAssertEqual(viewController.traitOverrides.preferredContentSizeCategory, .extraLarge)
    }

    /// `applyTextSize` preserves the system text size when it is larger than the selected text size.
    @available(iOS 17.0, *)
    func test_applyTextSize_systemTextSizeLargerThanSelected() {
        let viewController = UIViewController()

        viewController.applyTextSize(.large, systemContentSizeCategory: .accessibilityMedium)

        XCTAssertFalse(viewController.traitOverrides.contains(UITraitPreferredContentSizeCategory.self))
    }

    /// `applyTextSize` removes the override for the default text size.
    @available(iOS 17.0, *)
    func test_applyTextSize_defaultTextSize() {
        let viewController = UIViewController()

        viewController.applyTextSize(.default, systemContentSizeCategory: .accessibilityMedium)

        XCTAssertFalse(viewController.traitOverrides.contains(UITraitPreferredContentSizeCategory.self))
    }

    /// `defaultValueLocalizedName` has the expected value.
    func test_defaultValueLocalizedName() {
        XCTAssertEqual(TextSize.defaultValueLocalizedName, Localizations.defaultSystem)
    }

    /// `localizedName` has the expected values.
    func test_localizedName() {
        XCTAssertEqual(TextSize.default.localizedName, Localizations.defaultSystem)
        XCTAssertEqual(TextSize.large.localizedName, Localizations.large)
        XCTAssertEqual(TextSize.larger.localizedName, Localizations.larger)
        XCTAssertEqual(TextSize.largest.localizedName, Localizations.largest)
    }

    /// `value` has the expected values.
    func test_value() {
        XCTAssertNil(TextSize.default.value)
        XCTAssertEqual(TextSize.large.value, "large")
        XCTAssertEqual(TextSize.larger.value, "larger")
        XCTAssertEqual(TextSize.largest.value, "largest")
    }
}
