import Foundation

struct Obra: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let nome: String
    let endereco: String

    init(id: String = UUID().uuidString, nome: String, endereco: String = "") {
        self.id = id
        self.nome = nome
        self.endereco = endereco
    }
}
