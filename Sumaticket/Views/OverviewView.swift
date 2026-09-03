import SwiftUI
import SwiftData

struct OverviewView: View {
    @Query private var receipts: [Receipt]
    let onScan: () -> Void

    private var activeReceipts: [Receipt] {
        receipts.filter { !$0.isInTrash }
    }

    private var total: Double {
        activeReceipts.reduce(0) { $0 + $1.amount }
    }

    private var categoryGroups: [GeneralCategoryGroup] {
        ReceiptGrouping.generalCategories(from: activeReceipts)
    }

    private var recentReceipts: [Receipt] {
        activeReceipts.sorted { $0.purchaseDate > $1.purchaseDate }.prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    TotalCard(
                        title: "Total digitalizado",
                        amount: total,
                        subtitle: "\(activeReceipts.count) ticket\(activeReceipts.count == 1 ? "" : "s") guardado\(activeReceipts.count == 1 ? "" : "s")"
                    )

                    if !categoryGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Principales categorías")
                                .font(.headline)

                            ForEach(categoryGroups.prefix(4)) { group in
                                NavigationLink {
                                    GeneralCategoryDetailView(category: group.category)
                                } label: {
                                    LiquidGlassCard {
                                        HStack(spacing: 12) {
                                            Image(systemName: group.category.symbol)
                                                .font(.title3.weight(.semibold))
                                                .frame(width: 34)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(group.category.name)
                                                    .font(.body.weight(.semibold))
                                                Text("\(group.count) ticket\(group.count == 1 ? "" : "s")")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Text(group.total.currencyText)
                                                .font(.body.weight(.bold))
                                                .monospacedDigit()
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Últimos tickets")
                            .font(.headline)

                        if recentReceipts.isEmpty {
                            LiquidGlassCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Label("Aún no hay tickets", systemImage: "receipt")
                                        .font(.headline)
                                    Text("Escanea el primero y Sumaticket lo clasificará automáticamente.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Button("Escanear ticket", action: onScan)
                                        .buttonStyle(.borderedProminent)
                                }
                            }
                        } else {
                            ForEach(recentReceipts) { receipt in
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
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Sumaticket")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onScan) {
                        Image(systemName: "camera.viewfinder")
                    }
                    .accessibilityLabel("Escanear ticket")
                }
            }
        }
    }
}
