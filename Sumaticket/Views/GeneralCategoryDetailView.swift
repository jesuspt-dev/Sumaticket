import SwiftUI
import SwiftData

struct GeneralCategoryDetailView: View {
    @Query private var receipts: [Receipt]
    let category: GeneralCategory

    private var matchingReceipts: [Receipt] {
        receipts
            .filter { !$0.isInTrash && $0.generalCategoryID == category.id }
            .sorted { $0.purchaseDate > $1.purchaseDate }
    }

    private var total: Double {
        matchingReceipts.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                TotalCard(
                    title: "Total en \(category.name)",
                    amount: total,
                    subtitle: "Suma de todos los tickets de esta categoría"
                )

                ForEach(matchingReceipts) { receipt in
                    NavigationLink {
                        ReceiptDetailView(receipt: receipt)
                    } label: {
                        LiquidGlassCard {
                            ReceiptRow(receipt: receipt)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
