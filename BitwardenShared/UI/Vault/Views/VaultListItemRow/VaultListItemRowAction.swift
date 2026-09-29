// MARK: - VaultListItemRowAction

/// Actions that can be sent from a `VaultListItemRowView`.
enum VaultListItemRowAction: Equatable {
    /// The copy TOTP Code button was pressed.
    ///
    /// - Parameters:
    ///   - code: The TOTP code to copy.
    ///   - cipherId: The ID of the cipher that the TOTP code belongs to.
    ///
    case copyTOTPCode(_ code: String, cipherId: String)
}
