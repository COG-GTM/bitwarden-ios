import BitwardenKit

// MARK: - AppearanceAction

/// Actions handled by the `AppearanceProcessor`.
///
enum AppearanceAction: Equatable {
    /// The default color theme was changed.
    case appThemeChanged(AppTheme)

    /// The language option was tapped.
    case languageTapped

    /// The text size was changed.
    case textSizeChanged(TextSize)

    /// Show website icons was toggled.
    case toggleShowWebsiteIcons(Bool)
}
