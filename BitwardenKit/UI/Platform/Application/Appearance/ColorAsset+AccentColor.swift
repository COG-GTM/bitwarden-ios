import BitwardenResources
import SwiftUI
import UIKit

// MARK: - ColorAsset

public extension ColorAsset {
    /// A dynamic UIKit color that resolves to the user's selected `AppAccentColor`, falling back
    /// to this asset's color when the default accent color is selected.
    var themedColor: UIColor {
        let defaultColor: UIColor = color
        return UIColor { traitCollection in
            AppAccentColor.current.color(for: traitCollection)
                ?? defaultColor.resolvedColor(with: traitCollection)
        }
    }

    /// A SwiftUI color that resolves to the user's selected `AppAccentColor`, falling back to
    /// this asset's color when the default accent color is selected.
    var themedSwiftUIColor: SwiftUI.Color {
        SwiftUI.Color(uiColor: themedColor)
    }
}
