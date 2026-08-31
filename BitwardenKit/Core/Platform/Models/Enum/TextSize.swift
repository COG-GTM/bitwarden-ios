import BitwardenResources
import UIKit

// MARK: - TextSize

/// An enum listing the text size options used to scale the app's text.
///
public enum TextSize: String, Menuable, Sendable {
    /// Use the text size from the device's system settings.
    case `default`

    /// Use large text.
    case large

    /// Use larger text.
    case larger

    /// Use the largest text.
    case largest

    // MARK: Type Properties

    /// The ordered list of options to display in the menu.
    public static let allCases: [TextSize] = [.default, .large, .larger, .largest]

    // MARK: Properties

    /// Specify the text for the default option.
    public static var defaultValueLocalizedName: String { Localizations.defaultSystem }

    /// The content size category used to scale the app's text, or `nil` to use the size from the
    /// device's system settings.
    public var contentSizeCategory: UIContentSizeCategory? {
        switch self {
        case .default:
            nil
        case .large:
            .extraLarge
        case .larger:
            .extraExtraExtraLarge
        case .largest:
            .accessibilityMedium
        }
    }

    /// The name of the type to display in the dropdown menu.
    public var localizedName: String {
        switch self {
        case .default:
            Localizations.defaultSystem
        case .large:
            Localizations.large
        case .larger:
            Localizations.larger
        case .largest:
            Localizations.largest
        }
    }

    /// The value to save to the local storage.
    public var value: String? {
        switch self {
        case .default:
            nil
        case .large, .larger, .largest:
            rawValue
        }
    }

    // MARK: Initialization

    /// Initialize a `TextSize`.
    ///
    /// - Parameter textSize: The raw value string of the custom selection, or `nil` for default.
    ///
    public init(_ textSize: String?) {
        if let textSize {
            self = .init(rawValue: textSize) ?? .default
        } else {
            self = .default
        }
    }
}

// MARK: - UIViewController + TextSize

public extension UIViewController {
    /// Applies the specified text size to the view controller and its descendants, overriding the
    /// text size from the device's system settings.
    ///
    /// - Parameter textSize: The text size to apply.
    ///
    func applyTextSize(_ textSize: TextSize) {
        applyTextSize(
            textSize,
            systemContentSizeCategory: view.window?.windowScene?.traitCollection.preferredContentSizeCategory,
        )
    }

    internal func applyTextSize(
        _ textSize: TextSize,
        systemContentSizeCategory: UIContentSizeCategory?,
    ) {
        let contentSizeCategory = textSize.contentSizeCategory.flatMap { contentSizeCategory in
            guard let systemContentSizeCategory else { return contentSizeCategory }
            return systemContentSizeCategory < contentSizeCategory ? contentSizeCategory : nil
        }

        if #available(iOS 17.0, *) {
            if let contentSizeCategory {
                traitOverrides.preferredContentSizeCategory = contentSizeCategory
            } else {
                traitOverrides.remove(UITraitPreferredContentSizeCategory.self)
            }
        } else {
            let traitCollection = contentSizeCategory.map { contentSizeCategory in
                UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            }
            for child in children {
                setOverrideTraitCollection(traitCollection, forChild: child)
            }
        }
    }
}
