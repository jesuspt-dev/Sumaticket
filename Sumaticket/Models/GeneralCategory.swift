import Foundation

struct GeneralCategory: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String

    static let all: [GeneralCategory] = [
        .init(id: "food", name: "Comida", symbol: "fork.knife"),
        .init(id: "groceries", name: "Supermercado", symbol: "basket.fill"),
        .init(id: "clothing", name: "Ropa", symbol: "tshirt.fill"),
        .init(id: "fuel", name: "Gasolina", symbol: "fuelpump.fill"),
        .init(id: "games", name: "Juegos", symbol: "gamecontroller.fill"),
        .init(id: "technology", name: "Tecnología", symbol: "desktopcomputer"),
        .init(id: "home", name: "Hogar", symbol: "house.fill"),
        .init(id: "health", name: "Salud", symbol: "cross.case.fill"),
        .init(id: "transport", name: "Transporte", symbol: "car.fill"),
        .init(id: "services", name: "Servicios", symbol: "wrench.and.screwdriver.fill"),
        .init(id: "leisure", name: "Ocio", symbol: "ticket.fill"),
        .init(id: "travel", name: "Viajes", symbol: "airplane"),
        .init(id: "education", name: "Educación", symbol: "book.fill"),
        .init(id: "other", name: "Otros", symbol: "square.grid.2x2.fill")
    ]

    static func category(for id: String) -> GeneralCategory {
        all.first(where: { $0.id == id }) ?? all.last!
    }
}
