import BitwardenResources
import UIKit

// MARK: - AppAccentColor

/// An enum listing the accent color options used to tint interactive elements throughout the app.
///
public enum AppAccentColor: String, Menuable, Sendable {
    /// Use the default Bitwarden blue accent color.
    case `default`

    /// Use a green accent color.
    case green

    /// Use an orange accent color.
    case orange

    /// Use a pink accent color.
    case pink

    /// Use a purple accent color.
    case purple

    /// Use a teal accent color.
    case teal

    // MARK: Type Properties

    /// The ordered list of options to display in the menu.
    public static let allCases: [AppAccentColor] = [.default, .purple, .pink, .orange, .green, .teal]

    /// The accent color currently applied to the app's interface.
    public nonisolated(unsafe) static var current: AppAccentColor = .default

    /// Specify the text for the default option.
    public static var defaultValueLocalizedName: String { Localizations.blueDefault }

    // MARK: Properties

    /// The name of the type to display in the dropdown menu.
    public var localizedName: String {
        switch self {
        case .default:
            Localizations.blueDefault
        case .green:
            Localizations.green
        case .orange:
            Localizations.orange
        case .pink:
            Localizations.pink
        case .purple:
            Localizations.purple
        case .teal:
            Localizations.teal
        }
    }

    /// The value to save to the local storage.
    public var value: String? {
        self == .default ? nil : rawValue
    }

    // MARK: Initialization

    /// Initialize an `AppAccentColor`.
    ///
    /// - Parameter appAccentColor: The raw value string of the custom selection, or `nil` for default.
    ///
    public init(_ appAccentColor: String?) {
        if let appAccentColor {
            self = .init(rawValue: appAccentColor) ?? .default
        } else {
            self = .default
        }
    }

    // MARK: Methods

    /// Returns the accent color to use for the specified trait collection, or `nil` if the app's
    /// default asset colors should be used.
    ///
    /// - Parameter traitCollection: The trait collection used to determine light or dark mode.
    /// - Returns: The accent color for the trait collection, or `nil` for the default accent color.
    ///
    public func color(for traitCollection: UITraitCollection) -> UIColor? {
        let isDark = traitCollection.userInterfaceStyle == .dark
        let hex: UInt32? = switch self {
        case .default: nil
        case .green: isDark ? 0x6BD38F : 0x0C7A3E
        case .orange: isDark ? 0xFFA25C : 0xB34700
        case .pink: isDark ? 0xFF8FD0 : 0xC01176
        case .purple: isDark ? 0xB99CFF : 0x7B3FE4
        case .teal: isDark ? 0x5CD6E0 : 0x0B7285
        }
        guard let hex else { return nil }
        return UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1,
        )
    }
}
