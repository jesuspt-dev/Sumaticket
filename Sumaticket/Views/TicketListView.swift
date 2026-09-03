import SwiftUI
import SwiftData

struct TicketListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var receipts: [Receipt]
    @State private var searchText = ""
    let onScan: () -> Void

    private var visibleReceipts: [Receipt] {
        receipts
            .filter { !$0.isInTrash }
            .filter {
                searchText.isEmpty ||
                $0.merchantName.localizedCaseInsensitiveContains(searchText) ||
                $0.generalCategory.name.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.purchaseDate > $1.purchaseDate }
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleReceipts.isEmpty && searchText.isEmpty {
                    EmptyStateView(
                        symbol: "receipt",
                        title: "Sin tickets",
                        message: "Escanea un ticket para empezar tu archivo digital."
                    )
                } else {
                    List {
                        ForEach(visibleReceipts) { receipt in
                            NavigationLink {
                                ReceiptDetailView(receipt: receipt)
                            } label: {
                                ReceiptRow(receipt: receipt)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    TrashService.moveToTrash(receipt, context: modelContext)
                                } label: {
                                    Label("Papelera", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Todos los tickets")
            .searchable(text: $searchText, prompt: "Tienda o categoría")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onScan) {
                        Image(systemName: "camera.viewfinder")
                    }
                }
            }
        }
    }
}
