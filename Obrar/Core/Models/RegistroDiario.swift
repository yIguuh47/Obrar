import Foundation

struct RegistroDiario: Identifiable, Codable {
    struct Item: Identifiable, Codable, Hashable {
        let id: UUID
        let prestadorId: UUID
        let prestadorNome: String
        let obraNome: String

        init(id: UUID = UUID(), prestadorId: UUID, prestadorNome: String, obraNome: String) {
            self.id = id
            self.prestadorId = prestadorId
            self.prestadorNome = prestadorNome
            self.obraNome = obraNome
        }
    }

    let id: UUID
    let data: Date
    let itens: [Item]
    let atualizadoEm: Date

    init(id: UUID = UUID(), data: Date, itens: [Item], atualizadoEm: Date = Date()) {
        self.id = id
        self.data = data
        self.itens = itens
        self.atualizadoEm = atualizadoEm
    }
}
