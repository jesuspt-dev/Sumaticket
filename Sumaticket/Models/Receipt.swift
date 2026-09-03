import Foundation
import SwiftData

@Model
final class Receipt {
    @Attribute(.unique) var id: UUID
    var merchantName: String
    var merchantKey: String
    var amount: Double
    var purchaseDate: Date
    var generalCategoryID: String
    @Attribute(.externalStorage) var imageData: Data?
    var ocrText: String
    var createdAt: Date
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        merchantName: String,
        amount: Double,
        purchaseDate: Date,
        generalCategoryID: String,
        imageData: Data?,
        ocrText: String,
        createdAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.merchantName = merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.merchantKey = MerchantNormalizer.key(for: merchantName)
        self.amount = amount
        self.purchaseDate = purchaseDate
        self.generalCategoryID = generalCategoryID
        self.imageData = imageData
        self.ocrText = ocrText
        self.createdAt = createdAt
        self.deletedAt = deletedAt
    }

    var generalCategory: GeneralCategory {
        GeneralCategory.category(for: generalCategoryID)
    }

    var isInTrash: Bool {
        deletedAt != nil
    }
}

struct MerchantNormalizer {
    static func key(for value: String) -> String {
        var normalized = value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .uppercased()
            .replacingOccurrences(of: "&", with: " Y ")
            .replacingOccurrences(of: "[^A-Z0-9]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        normalized = normalized.replacingOccurrences(
            of: #"\s+(S L U|S L|S A U|S A|SLU|SL|SAU|SA)$"#,
            with: "",
            options: .regularExpression
        )
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
