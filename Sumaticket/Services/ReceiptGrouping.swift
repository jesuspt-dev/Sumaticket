import Foundation

struct MerchantGroup: Identifiable {
    let id: String
    let name: String
    let receipts: [Receipt]

    var total: Double { receipts.reduce(0) { $0 + $1.amount } }
    var count: Int { receipts.count }
}

struct GeneralCategoryGroup: Identifiable {
    let category: GeneralCategory
    let receipts: [Receipt]

    var id: String { category.id }
    var total: Double { receipts.reduce(0) { $0 + $1.amount } }
    var count: Int { receipts.count }
}

enum ReceiptGrouping {
    static func merchants(from receipts: [Receipt]) -> [MerchantGroup] {
        let grouped = Dictionary(grouping: receipts) { $0.merchantKey }
        return grouped.map { key, values in
            let preferredName = values
                .map(\.merchantName)
                .sorted { $0.count < $1.count }
                .first ?? "Establecimiento"
            return MerchantGroup(id: key, name: preferredName, receipts: values.sorted { $0.purchaseDate > $1.purchaseDate })
        }
        .sorted { lhs, rhs in
            if lhs.total == rhs.total {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.total > rhs.total
        }
    }

    static func generalCategories(from receipts: [Receipt]) -> [GeneralCategoryGroup] {
        let grouped = Dictionary(grouping: receipts) { $0.generalCategoryID }
        return GeneralCategory.all.compactMap { category in
            guard let values = grouped[category.id], !values.isEmpty else { return nil }
            return GeneralCategoryGroup(
                category: category,
                receipts: values.sorted { $0.purchaseDate > $1.purchaseDate }
            )
        }
        .sorted { $0.total > $1.total }
    }
}
