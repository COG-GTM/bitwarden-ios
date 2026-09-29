import BitwardenKit
import BitwardenResources
import UIKit
import XCTest

class AppAccentColorTests: BitwardenTestCase {
    // MARK: Tests

    /// `init` returns the expected values.
    func test_init() {
        XCTAssertEqual(AppAccentColor(nil), .default)
        XCTAssertEqual(AppAccentColor("green"), .green)
        XCTAssertEqual(AppAccentColor("orange"), .orange)
        XCTAssertEqual(AppAccentColor("pink"), .pink)
        XCTAssertEqual(AppAccentColor("purple"), .purple)
        XCTAssertEqual(AppAccentColor("teal"), .teal)
        XCTAssertEqual(AppAccentColor("gibberish"), .default)
    }

    /// `allCases` contains all accent colors in the expected order.
    func test_allCases() {
        XCTAssertEqual(AppAccentColor.allCases, [.default, .purple, .pink, .orange, .green, .teal])
    }

    /// `color(for:)` returns `nil` for the default accent color and a color for custom accent colors.
    func test_color() {
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)

        XCTAssertNil(AppAccentColor.default.color(for: light))
        XCTAssertNil(AppAccentColor.default.color(for: dark))

        for accentColor in AppAccentColor.allCases where accentColor != .default {
            let lightColor = accentColor.color(for: light)
            let darkColor = accentColor.color(for: dark)
            XCTAssertNotNil(lightColor)
            XCTAssertNotNil(darkColor)
            XCTAssertNotEqual(lightColor, darkColor)
        }
    }

    /// `defaultValueLocalizedName` has the expected value.
    func test_defaultValueLocalizedName() {
        XCTAssertEqual(AppAccentColor.defaultValueLocalizedName, Localizations.blueDefault)
    }

    /// `localizedName` has the expected values.
    func test_localizedName() {
        XCTAssertEqual(AppAccentColor.default.localizedName, Localizations.blueDefault)
        XCTAssertEqual(AppAccentColor.green.localizedName, Localizations.green)
        XCTAssertEqual(AppAccentColor.orange.localizedName, Localizations.orange)
        XCTAssertEqual(AppAccentColor.pink.localizedName, Localizations.pink)
        XCTAssertEqual(AppAccentColor.purple.localizedName, Localizations.purple)
        XCTAssertEqual(AppAccentColor.teal.localizedName, Localizations.teal)
    }

    /// `value` has the expected values.
    func test_value() {
        XCTAssertNil(AppAccentColor.default.value)
        XCTAssertEqual(AppAccentColor.green.value, "green")
        XCTAssertEqual(AppAccentColor.orange.value, "orange")
        XCTAssertEqual(AppAccentColor.pink.value, "pink")
        XCTAssertEqual(AppAccentColor.purple.value, "purple")
        XCTAssertEqual(AppAccentColor.teal.value, "teal")
    }
}
