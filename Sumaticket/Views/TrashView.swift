import SwiftUI
import SwiftData

struct TrashView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var receipts: [Receipt]
    @State private var permanentDeleteTarget: Receipt?

    private var trashed: [Receipt] {
        receipts
            .filter { $0.isInTrash }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    var body: some View {
        Group {
            if trashed.isEmpty {
                EmptyStateView(
                    symbol: "trash",
                    title: "Papelera vacía",
                    message: "Los tickets eliminados permanecen aquí durante 30 días."
                )
            } else {
                List {
                    Section {
                        ForEach(trashed) { receipt in
                            VStack(alignment: .leading, spacing: 7) {
                                ReceiptRow(receipt: receipt)
                                Text("Se eliminará automáticamente en \(TrashService.daysRemaining(for: receipt)) día(s)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    TrashService.restore(receipt, context: modelContext)
                                } label: {
                                    Label("Recuperar", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    permanentDeleteTarget = receipt
                                } label: {
                                    Label("Eliminar", systemImage: "trash.slash")
                                }
                            }
                        }
                    } header: {
                        EmptyView()
                    } footer: {
                        Text("Los tickets se eliminan definitivamente al cumplirse 30 días en la papelera.")
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Papelera")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            TrashService.purgeExpired(from: receipts, context: modelContext)
        }
        .confirmationDialog(
            "Eliminar definitivamente",
            isPresented: Binding(
                get: { permanentDeleteTarget != nil },
                set: { if !$0 { permanentDeleteTarget = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Eliminar definitivamente", role: .destructive) {
                if let target = permanentDeleteTarget {
                    modelContext.delete(target)
                    try? modelContext.save()
                }
                permanentDeleteTarget = nil
            }
            Button("Cancelar", role: .cancel) {
                permanentDeleteTarget = nil
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
    }
}
