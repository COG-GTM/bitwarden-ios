// swiftlint:disable:this file_name

extension [VaultListItem] {
    /// Group the array into a dictionary sorted by id.
    ///
    /// - Returns: A dictionary of the array elements sorted by id.
    ///
    func byId() -> [String: VaultListItem] {
        var result = [String: VaultListItem]()
        forEach { result[$0.id] = $0 }
        return result
    }

    /// Update the array with a batch of possible updates, preserving the order of the existing items.
    /// Any new values are appended to the end of the array, sorted by name.
    ///
    /// - Parameters:
    ///   - updatedValues: An array of updates to make the items are found in the current array.
    ///   - includeNewValues: A flag for including new values not found in the current array. Default is `false`.
    /// - Returns: An updated version of the array including the new elements.
    ///
    func updated(
        with updatedValues: [VaultListItem],
        includeNewValues: Bool = false,
    ) -> [VaultListItem] {
        let updatedById = updatedValues.byId()
        let existingIds = Set(map(\.id))
        let existingItems = map { updatedById[$0.id] ?? $0 }
        guard includeNewValues else { return existingItems }
        let newItems = updatedValues
            .filter { !existingIds.contains($0.id) }
            .sorted { $0.sortValue.localizedStandardCompare($1.sortValue) == .orderedAscending }
        return existingItems + newItems
    }
}

extension [VaultListSection] {
    /// Update the array of sections with a batch of possible item updates.
    ///
    /// - Parameters:
    ///   - updatedValues: An array of updates to make the items within the sections.
    ///   - includeNewValues: A flag for including new values not found in the current list. Default is `false`.
    /// - Returns: An updated version of the array including the updated elements.
    ///
    func updated(
        with updatedValues: [VaultListItem],
        includeNewValues: Bool = false,
    ) -> [VaultListSection] {
        map { section in
            let updatedItems = section.items.updated(with: updatedValues, includeNewValues: includeNewValues)
            return VaultListSection(id: section.id, items: updatedItems, name: section.name)
        }
    }
}
