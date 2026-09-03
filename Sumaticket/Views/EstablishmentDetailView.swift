import SwiftUI
import SwiftData

struct EstablishmentDetailView: View {
    @Query private var receipts: [Receipt]
    let merchantKey: String
    let merchantName: String

    private var matchingReceipts: [Receipt] {
        receipts
            .filter { !$0.isInTrash && $0.merchantKey == merchantKey }
            .sorted { $0.purchaseDate > $1.purchaseDate }
    }

    private var total: Double {
        matchingReceipts.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                TotalCard(
                    title: "Total en \(merchantName)",
                    amount: total,
                    subtitle: "Suma de todos los tickets de este establecimiento"
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
        .navigationTitle(merchantName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
