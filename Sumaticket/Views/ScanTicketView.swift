import SwiftUI
import PhotosUI
import UIKit

struct ScanTicketView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var scanResult: ScannedReceipt?
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 68, weight: .light))
                    .foregroundStyle(.tint)

                VStack(spacing: 8) {
                    Text("Digitaliza un ticket")
                        .font(.title2.bold())
                    Text("Encuadra todo el ticket, evita reflejos y procura que el importe total sea legible.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                if isProcessing {
                    LiquidGlassCard {
                        HStack(spacing: 12) {
                            ProgressView()
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Leyendo ticket…")
                                    .fontWeight(.semibold)
                                Text("Detectando establecimiento, importe y categoría")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        Button {
                            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                                errorMessage = "La cámara no está disponible en este dispositivo."
                                return
                            }
                            showCamera = true
                        } label: {
                            Label("Sacar foto", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label("Elegir de Fotos", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Escanear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker(
                onImage: { image in
                    showCamera = false
                    process(image)
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
        .sheet(item: $scanResult) { item in
            if let capturedImage {
                ReviewScanView(scanned: item, image: capturedImage) {
                    scanResult = nil
                    dismiss()
                } onRescan: {
                    scanResult = nil
                    self.capturedImage = nil
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                do {
                    guard let data = try await newItem.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        errorMessage = "No se pudo cargar la imagen seleccionada."
                        return
                    }
                    process(image)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .alert("No se pudo leer el ticket", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("Aceptar", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Error desconocido")
        }
    }

    private func process(_ image: UIImage) {
        capturedImage = image
        isProcessing = true
        errorMessage = nil

        Task {
            let result = await Task.detached(priority: .userInitiated) { () -> Result<ScannedReceipt, Error> in
                do {
                    return .success(try ReceiptScannerService.scan(image: image))
                } catch {
                    return .failure(error)
                }
            }.value

            await MainActor.run {
                isProcessing = false
                switch result {
                case .success(let scanned):
                    scanResult = scanned
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

