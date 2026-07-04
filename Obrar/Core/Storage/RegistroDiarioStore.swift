import Foundation

protocol RegistroDiarioStoreProtocol {
    func fetchAll() throws -> [RegistroDiario]
    func fetch(for date: Date) throws -> RegistroDiario?
    func upsert(for date: Date, itens: [RegistroDiario.Item]) throws
}

final class UserDefaultsRegistroDiarioStore: RegistroDiarioStoreProtocol {
    private let key = "obrar.registros-diarios"
    private let seedVersionKey = "obrar.registros-diarios.seed.version"
    private let seedVersion = 1
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let calendar = Calendar.current

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        seedFakeDataIfNeeded()
    }

    func fetchAll() throws -> [RegistroDiario] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        return try decoder.decode([RegistroDiario].self, from: data)
    }

    func fetch(for date: Date) throws -> RegistroDiario? {
        let startOfDay = calendar.startOfDay(for: date)
        return try fetchAll().first { calendar.isDate($0.data, inSameDayAs: startOfDay) }
    }

    func upsert(for date: Date, itens: [RegistroDiario.Item]) throws {
        let startOfDay = calendar.startOfDay(for: date)
        var current = try fetchAll().filter { !calendar.isDate($0.data, inSameDayAs: startOfDay) }
        let registro = RegistroDiario(data: startOfDay, itens: itens)
        current.append(registro)
        let data = try encoder.encode(current.sorted(by: { $0.data > $1.data }))
        defaults.set(data, forKey: key)
    }

    private func seedFakeDataIfNeeded() {
        guard defaults.integer(forKey: seedVersionKey) < seedVersion else {
            return
        }

        let fake = makeFakeRegistros()
        guard !fake.isEmpty else { return }

        do {
            let current = try fetchAll()
            let merged = (current + fake).sorted { $0.data > $1.data }
            let data = try encoder.encode(merged)
            defaults.set(data, forKey: key)
            defaults.set(seedVersion, forKey: seedVersionKey)
        } catch {
            // Fake seed should not block app startup.
        }
    }

    private func makeFakeRegistros() -> [RegistroDiario] {
        let now = Date()
        let offsets = [0, 1, 2, 4, 6, 9, 12, 15, 18, 22, 27, 31, 36, 42, 49, 56]
        let names = [
            "João Silva", "Marcos Pereira", "Rafael Gomes", "Carlos Souza",
            "Diego Oliveira", "André Lima", "Paulo Santos", "Felipe Costa"
        ]
        let obras = [
            "Residencial Primavera",
            "Reforma Apartamento Centro",
            "Obra Comercial - Loja 12"
        ]

        return offsets.compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: now) else {
                return nil
            }
            let day = calendar.startOfDay(for: date)
            let quantity = 2 + (offset % 3)

            let items: [RegistroDiario.Item] = (0..<quantity).map { index in
                let name = names[(offset + index) % names.count]
                let obra = obras[(offset + index) % obras.count]
                return RegistroDiario.Item(
                    prestadorId: UUID(),
                    prestadorNome: name,
                    obraNome: obra
                )
            }

            return RegistroDiario(data: day, itens: items)
        }
    }
}
