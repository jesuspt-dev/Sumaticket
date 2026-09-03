import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var receipts: [Receipt]
    @State private var showScanner = false

    var body: some View {
        TabView {
            OverviewView(onScan: { showScanner = true })
                .tabItem { Label("Resumen", systemImage: "chart.pie.fill") }

            TicketListView(onScan: { showScanner = true })
                .tabItem { Label("Tickets", systemImage: "receipt.fill") }

            EstablishmentsView()
                .tabItem { Label("Tiendas", systemImage: "building.2.fill") }

            GeneralCategoriesView()
                .tabItem { Label("Categorías", systemImage: "square.grid.2x2.fill") }

            SettingsView()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .tint(.blue)
        .sheet(isPresented: $showScanner) {
            ScanTicketView()
        }
        .task {
            TrashService.purgeExpired(from: receipts, context: modelContext)
        }
    }
}
