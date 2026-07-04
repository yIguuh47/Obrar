import Foundation

protocol ObraStoreProtocol {
    func fetchAll() throws -> [Obra]
    func save(_ obra: Obra) throws
}

final class UserDefaultsObraStore: ObraStoreProtocol {
    private let key = "obrar.obras"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        seedDefaultObrasIfNeeded()
    }

    func fetchAll() throws -> [Obra] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        return try decoder.decode([Obra].self, from: data)
    }

    func save(_ obra: Obra) throws {
        var current = try fetchAll()
        let exists = current.contains {
            $0.nome.caseInsensitiveCompare(obra.nome) == .orderedSame
        }

        guard !exists else {
            return
        }

        current.append(obra)
        let data = try encoder.encode(current)
        defaults.set(data, forKey: key)
    }

    private func seedDefaultObrasIfNeeded() {
        let obrasIniciais = [
            Obra(nome: "Residencial Primavera"),
            Obra(nome: "Reforma Apartamento Centro"),
            Obra(nome: "Obra Comercial - Loja 12")
        ]

        do {
            let current = try fetchAll()
            guard current.isEmpty else {
                return
            }
            let data = try encoder.encode(obrasIniciais)
            defaults.set(data, forKey: key)
        } catch {
            // Do not block app flow if seed fails.
        }
    }
}
