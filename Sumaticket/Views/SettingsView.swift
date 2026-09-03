import SwiftUI

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Apariencia") {
                    Picker("Modo", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Datos") {
                    NavigationLink {
                        TrashView()
                    } label: {
                        Label("Papelera", systemImage: "trash")
                    }
                }

                Section {
                    Label("Procesamiento local", systemImage: "lock.shield.fill")
                    Text("El OCR, las imágenes y los importes se guardan y procesan en tu iPhone. Sumaticket no necesita cuenta ni servicios externos.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Privacidad")
                }

                Section("Sumaticket") {
                    LabeledContent("Versión", value: "1.0.0")
                    LabeledContent("Papelera", value: "30 días")
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
