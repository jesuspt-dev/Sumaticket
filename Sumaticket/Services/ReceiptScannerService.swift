import Foundation
import UIKit
import Vision

struct ScannedReceipt: Identifiable {
    let id = UUID()
    let merchantName: String
    let amount: Double
    let purchaseDate: Date
    let generalCategoryID: String
    let ocrText: String
}

enum ReceiptScannerError: LocalizedError {
    case invalidImage
    case noText

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "No se pudo procesar la imagen del ticket."
        case .noText:
            return "No se detectó texto legible. Prueba con más luz y encuadrando todo el ticket."
        }
    }
}

enum ReceiptScannerService {
    static func scan(image: UIImage) throws -> ScannedReceipt {
        guard let normalized = image.normalizedForOCR().cgImage else {
            throw ReceiptScannerError.invalidImage
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["es-ES", "en-US"]
        request.minimumTextHeight = 0.009

        let handler = VNImageRequestHandler(cgImage: normalized, options: [:])
        try handler.perform([request])

        let observations = (request.results ?? []).sorted {
            if abs($0.boundingBox.maxY - $1.boundingBox.maxY) > 0.015 {
                return $0.boundingBox.maxY > $1.boundingBox.maxY
            }
            return $0.boundingBox.minX < $1.boundingBox.minX
        }

        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else {
            throw ReceiptScannerError.noText
        }

        let fullText = lines.joined(separator: "\n")
        let merchant = detectMerchant(lines: lines)
        let amount = detectTotal(lines: lines)
        let date = detectDate(lines: lines) ?? Date()
        let category = classify(merchant: merchant, text: fullText)

        return ScannedReceipt(
            merchantName: merchant,
            amount: amount,
            purchaseDate: date,
            generalCategoryID: category.id,
            ocrText: fullText
        )
    }

    private static func detectMerchant(lines: [String]) -> String {
        let ignored = [
            "TICKET", "FACTURA", "SIMPLIFICADA", "RECIBO", "COPIA", "CLIENTE",
            "CIF", "NIF", "N.I.F", "IVA", "VAT", "TOTAL", "IMPORTE", "FECHA",
            "HORA", "TEL", "TELEFONO", "WWW", "HTTP", "GRACIAS", "CAJA",
            "OPERACION", "DOCUMENTO", "DIRECCION", "C.P", "CP "
        ]

        var bestLine: String?
        var bestScore = Int.min

        for (index, raw) in lines.prefix(14).enumerated() {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            let upper = line.uppercased()
            let letters = line.filter { $0.isLetter }.count
            guard letters >= 3, line.count <= 54 else { continue }
            guard !ignored.contains(where: { upper.contains($0) }) else { continue }
            guard line.range(of: #"^\s*[€$]?\s*\d+[,.]\d{2}\s*$"#, options: .regularExpression) == nil else { continue }

            let uppercaseLetters = line.filter { $0.isLetter && $0.isUppercase }.count
            let uppercaseRatio = letters > 0 ? Double(uppercaseLetters) / Double(letters) : 0
            var score = 50 - (index * 3)
            if uppercaseRatio > 0.65 { score += 12 }
            if line.count >= 5 && line.count <= 28 { score += 8 }
            if upper.contains("SL") || upper.contains("SA") { score += 2 }

            if score > bestScore {
                bestScore = score
                bestLine = line
            }
        }

        let candidate = bestLine ?? lines.first ?? "Establecimiento"
        return cleanMerchant(candidate)
    }

    private static func cleanMerchant(_ value: String) -> String {
        var result = value
            .replacingOccurrences(of: #"^[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9]+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 .&'\-]+$"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if result.isEmpty { result = "Establecimiento" }
        return result
    }

    private static func detectTotal(lines: [String]) -> Double {
        let keywords = ["TOTAL A PAGAR", "IMPORTE TOTAL", "TOTAL EUR", "TOTAL €", "TOTAL", "A PAGAR", "IMPORTE"]

        for keyword in keywords {
            for index in lines.indices.reversed() {
                let upper = lines[index].uppercased()
                guard upper.contains(keyword) else { continue }

                var joined = lines[index]
                if index + 1 < lines.count {
                    joined += " " + lines[index + 1]
                }

                let values = moneyValues(in: joined)
                if let value = values.last, value >= 0 {
                    return value
                }
            }
        }

        let allValues = lines.flatMap { moneyValues(in: $0) }
            .filter { $0 >= 0 && $0 < 100_000 }
        return allValues.max() ?? 0
    }

    private static func moneyValues(in text: String) -> [Double] {
        let pattern = #"(?<!\d)(\d{1,5}(?:[.\s]\d{3})*(?:[,.]\d{2}))(?!\d)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)

        return regex.matches(in: text, range: nsRange).compactMap { match in
            guard let range = Range(match.range(at: 1), in: text) else { return nil }
            var raw = String(text[range]).replacingOccurrences(of: " ", with: "")

            if raw.contains(",") {
                raw = raw.replacingOccurrences(of: ".", with: "")
                raw = raw.replacingOccurrences(of: ",", with: ".")
            }
            return Double(raw)
        }
    }

    private static func detectDate(lines: [String]) -> Date? {
        let pattern = #"\b(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        for line in lines {
            let nsRange = NSRange(line.startIndex..<line.endIndex, in: line)
            guard let match = regex.firstMatch(in: line, range: nsRange),
                  let dayRange = Range(match.range(at: 1), in: line),
                  let monthRange = Range(match.range(at: 2), in: line),
                  let yearRange = Range(match.range(at: 3), in: line),
                  let day = Int(line[dayRange]),
                  let month = Int(line[monthRange]),
                  var year = Int(line[yearRange]) else { continue }

            if year < 100 { year += 2000 }
            var components = DateComponents()
            components.calendar = Calendar(identifier: .gregorian)
            components.day = day
            components.month = month
            components.year = year

            if let date = components.date { return date }
        }
        return nil
    }

    private static func classify(merchant: String, text: String) -> GeneralCategory {
        let haystack = (merchant + " " + text).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()

        let rules: [(String, [String])] = [
            ("fuel", ["repsol", "cepsa", "bp ", "shell", "galp", "gasolina", "gasoil", "diesel", "combustible", "gasolinera"]),
            ("clothing", ["zara", "bershka", "pull&bear", "pull and bear", "stradivarius", "mango", "primark", "h&m", "ropa", "textil", "moda"]),
            ("games", ["game ", "gamestop", "steam", "playstation", "xbox", "nintendo", "videojuego", "gaming"]),
            ("technology", ["mediamarkt", "apple", "pccomponentes", "fnac", "electronica", "informatica", "ordenador", "smartphone"]),
            ("groceries", ["mercadona", "carrefour", "lidl", "aldi", "dia ", "alcampo", "supermercado", "hipermercado"]),
            ("food", ["restaurant", "restaurante", "cafeteria", "bar ", "burger", "pizza", "mcdonald", "kfc", "starbucks", "tapas", "menu"]),
            ("health", ["farmacia", "pharmacy", "clinica", "dental", "optica", "salud"]),
            ("transport", ["renfe", "uber", "cabify", "taxi", "parking", "aparcamiento", "metro", "autobus"]),
            ("home", ["ikea", "leroy merlin", "bricomart", "obramat", "mueble", "hogar", "ferreteria"]),
            ("travel", ["hotel", "hostal", "booking", "airbnb", "iberia", "ryanair", "vueling", "aerolinea"]),
            ("education", ["libreria", "academia", "universidad", "curso", "formacion", "papeleria"]),
            ("services", ["telefonica", "movistar", "vodafone", "orange", "internet", "electricidad", "energia", "seguro", "reparacion", "servicio"]),
            ("leisure", ["cine", "cinema", "teatro", "museo", "concierto", "entrada", "ocio"])
        ]

        for (id, words) in rules where words.contains(where: { haystack.contains($0) }) {
            return GeneralCategory.category(for: id)
        }
        return GeneralCategory.category(for: "other")
    }
}

private extension UIImage {
    func normalizedForOCR() -> UIImage {
        if imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
