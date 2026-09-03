import SwiftUI
import SwiftData

struct ReceiptDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let receipt: Receipt
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TicketPhotoView(data: receipt.imageData)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                TotalCard(title: receipt.merchantName, amount: receipt.amount)

                LiquidGlassCard {
                    VStack(spacing: 14) {
                        detailRow(title: "Fecha", value: receipt.purchaseDate.formatted(date: .long, time: .omitted), symbol: "calendar")
                        Divider()
                        detailRow(title: "Categoría", value: receipt.generalCategory.name, symbol: receipt.generalCategory.symbol)
                        Divider()
                        detailRow(title: "Establecimiento", value: receipt.merchantName, symbol: "storefront")
                    }
                }

                if !receipt.ocrText.isEmpty {
                    DisclosureGroup("Texto digitalizado") {
                        Text(receipt.ocrText)
                            .font(.caption.monospaced())
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Ticket")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Mover a la papelera",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mover a la papelera", role: .destructive) {
                TrashService.moveToTrash(receipt, context: modelContext)
                dismiss()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Podrás recuperarlo durante 30 días.")
        }
    }

    private func detailRow(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 28)
                .foregroundStyle(.tint)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.semibold)
        }
    }
}
