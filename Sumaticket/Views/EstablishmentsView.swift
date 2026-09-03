import SwiftUI
import SwiftData

struct EstablishmentsView: View {
    @Query private var receipts: [Receipt]
    @State private var searchText = ""

    private var groups: [MerchantGroup] {
        let active = receipts.filter { !$0.isInTrash }
        let result = ReceiptGrouping.merchants(from: active)
        guard !searchText.isEmpty else { return result }
        return result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if groups.isEmpty && searchText.isEmpty {
                    EmptyStateView(
                        symbol: "building.2",
                        title: "Sin establecimientos",
                        message: "Las categorías por tienda se crean automáticamente al guardar tickets."
                    )
                } else {
                    List(groups) { group in
                        NavigationLink {
                            EstablishmentDetailView(merchantKey: group.id, merchantName: group.name)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "storefront.fill")
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.tint)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(group.name)
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
            .navigationTitle("Establecimientos")
            .searchable(text: $searchText, prompt: "Buscar establecimiento")
        }
    }
}
