import SwiftUI
import SwiftData
import UIKit

struct ReviewScanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let scanned: ScannedReceipt
    let image: UIImage
    let onSaved: () -> Void
    let onRescan: () -> Void

    @State private var merchantName: String
    @State private var amountText: String
    @State private var purchaseDate: Date
    @State private var generalCategoryID: String
    @State private var showValidationError = false

    init(
        scanned: ScannedReceipt,
        image: UIImage,
        onSaved: @escaping () -> Void,
        onRescan: @escaping () -> Void
    ) {
        self.scanned = scanned
        self.image = image
        self.onSaved = onSaved
        self.onRescan = onRescan
        _merchantName = State(initialValue: scanned.merchantName)
        _amountText = State(initialValue: String(format: "%.2f", locale: Locale(identifier: "es_ES"), scanned.amount))
        _purchaseDate = State(initialValue: scanned.purchaseDate)
        _generalCategoryID = State(initialValue: scanned.generalCategoryID)
    }

    private var parsedAmount: Double? {
        var normalized = amountText
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")

        if normalized.contains(",") && normalized.contains(".") {
            normalized = normalized.replacingOccurrences(of: ".", with: "")
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        } else if normalized.contains(",") {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }
        return Double(normalized)
    }

    private var isValid: Bool {
        !merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (parsedAmount ?? -1) >= 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } header: {
                    Text("Ticket detectado")
                } footer: {
                    Text("Comprueba los datos antes de guardar. Puedes corregir cualquier campo.")
                }

                Section("Datos") {
                    TextField("Establecimiento", text: $merchantName)
                        .textInputAutocapitalization(.words)

                    HStack {
                        Text("Importe")
                        Spacer()
                        TextField("0,00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 130)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }

                    DatePicker("Fecha", selection: $purchaseDate, displayedComponents: .date)

                    Picker("Categoría", selection: $generalCategoryID) {
                        ForEach(GeneralCategory.all) { category in
                            Label(category.name, systemImage: category.symbol)
                                .tag(category.id)
                        }
                    }
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Label("Confirmar y guardar", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!isValid)

                    Button(role: .destructive) {
                        dismiss()
                        onRescan()
                    } label: {
                        Label("Repetir escaneo", systemImage: "camera.rotate")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("¿Es correcto?")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .alert("Revisa los datos", isPresented: $showValidationError) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text("El establecimiento no puede estar vacío y el importe debe ser un número válido.")
            }
        }
    }

    private func save() {
        guard let amount = parsedAmount, amount >= 0 else {
            showValidationError = true
            return
        }

        let data = image.jpegData(compressionQuality: 0.78)
        let receipt = Receipt(
            merchantName: merchantName,
            amount: amount,
            purchaseDate: purchaseDate,
            generalCategoryID: generalCategoryID,
            imageData: data,
            ocrText: scanned.ocrText
        )
        modelContext.insert(receipt)

        do {
            try modelContext.save()
            dismiss()
            onSaved()
        } catch {
            modelContext.delete(receipt)
            showValidationError = true
        }
    }
}
