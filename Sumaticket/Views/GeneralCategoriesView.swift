import SwiftUI
import SwiftData

struct GeneralCategoriesView: View {
    @Query private var receipts: [Receipt]

    private var groups: [GeneralCategoryGroup] {
        ReceiptGrouping.generalCategories(from: receipts.filter { !$0.isInTrash })
    }

    var body: some View {
        NavigationStack {
            Group {
                if groups.isEmpty {
                    EmptyStateView(
                        symbol: "square.grid.2x2",
                        title: "Sin categorías",
                        message: "Sumaticket asignará una categoría general a cada ticket durante el escaneo."
                    )
                } else {
                    List(groups) { group in
                        NavigationLink {
                            GeneralCategoryDetailView(category: group.category)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: group.category.symbol)
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.tint)
                                VStack(alignment: .leading, spacing: 3) {
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
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Categorías")
        }
    }
}
