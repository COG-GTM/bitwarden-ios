import BitwardenKit

// MARK: - AppearanceAction

/// Actions handled by the `AppearanceProcessor`.
///
enum AppearanceAction: Equatable {
    /// The accent color was changed.
    case appAccentColorChanged(AppAccentColor)

    /// The default color theme was changed.
    case appThemeChanged(AppTheme)

    /// The language option was tapped.
    case languageTapped

    /// Show website icons was toggled.
    case toggleShowWebsiteIcons(Bool)
}
