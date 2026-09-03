import Foundation
import SwiftData

enum TrashService {
    static let retentionDays = 30

    static func moveToTrash(_ receipt: Receipt, context: ModelContext) {
        receipt.deletedAt = Date()
        try? context.save()
    }

    static func restore(_ receipt: Receipt, context: ModelContext) {
        receipt.deletedAt = nil
        try? context.save()
    }

    static func purgeExpired(from receipts: [Receipt], context: ModelContext, now: Date = Date()) {
        let calendar = Calendar.current
        for receipt in receipts {
            guard let deletedAt = receipt.deletedAt,
                  let expiration = calendar.date(byAdding: .day, value: retentionDays, to: deletedAt),
                  expiration <= now else { continue }
            context.delete(receipt)
        }
        try? context.save()
    }

    static func daysRemaining(for receipt: Receipt, now: Date = Date()) -> Int {
        guard let deletedAt = receipt.deletedAt,
              let expiration = Calendar.current.date(byAdding: .day, value: retentionDays, to: deletedAt) else {
            return retentionDays
        }
        let days = Calendar.current.dateComponents([.day], from: now, to: expiration).day ?? 0
        return max(0, days)
    }
}
