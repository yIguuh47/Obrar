import Foundation

protocol PrestadorStoreProtocol {
    func fetchAll() throws -> [Prestador]
    func save(_ prestador: Prestador) throws
}

final class UserDefaultsPrestadorStore: PrestadorStoreProtocol {
    private let key = "obrar.prestadores"
    private let seedVersionKey = "obrar.prestadores.seed.version"
    private let seedVersion = 1
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        seedFakeDataIfNeeded()
    }

    func fetchAll() throws -> [Prestador] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        return try decoder.decode([Prestador].self, from: data)
    }

    func save(_ prestador: Prestador) throws {
        var current = try fetchAll()
        current.append(prestador)
        let data = try encoder.encode(current)
        defaults.set(data, forKey: key)
    }

    private func seedFakeDataIfNeeded() {
        guard defaults.integer(forKey: seedVersionKey) < seedVersion else {
            return
        }

        let fakeData = makeFakePrestadores()
        guard !fakeData.isEmpty else {
            return
        }

        do {
            var current = try fetchAll()
            current.append(contentsOf: fakeData)
            let merged = deduplicating(current)
            let data = try encoder.encode(merged)
            defaults.set(data, forKey: key)
            defaults.set(seedVersion, forKey: seedVersionKey)
        } catch {
            // Intentionally keep silent: fake seed should never block app usage.
        }
    }

    private func deduplicating(_ prestadores: [Prestador]) -> [Prestador] {
        var seen = Set<String>()
        var result: [Prestador] = []

        for prestador in prestadores {
            let dayStamp = Calendar.current.startOfDay(for: prestador.criadoEm).timeIntervalSince1970
            let signature = "\(prestador.nome.lowercased())-\(Int(dayStamp))"
            if seen.insert(signature).inserted {
                result.append(prestador)
            }
        }

        return result.sorted { $0.criadoEm > $1.criadoEm }
    }

    private func makeFakePrestadores() -> [Prestador] {
        let calendar = Calendar.current
        let now = Date()

        let names = [
            "João Silva", "Marcos Pereira", "Rafael Gomes", "Carlos Souza",
            "Diego Oliveira", "André Lima", "Paulo Santos", "Felipe Costa",
            "Bruno Martins", "Lucas Almeida", "Thiago Rocha", "Mateus Nunes",
            "Vinicius Araujo", "Eduardo Teixeira", "Renato Barros", "Leandro Freitas"
        ]

        let jobs = [
            "Pedreiro", "Eletricista", "Pintor", "Azulejista",
            "Encanador", "Servente", "Carpinteiro", "Gesseiro"
        ]

        let works = [
            "Residencial Primavera",
            "Reforma Apartamento Centro",
            "Obra Comercial - Loja 12",
            "Condomínio Sol Nascente"
        ]

        let dayOffsets = [0, 1, 2, 3, 5, 7, 9, 12, 14, 16, 19, 22, 25, 29, 33, 37, 41, 46, 52, 58]

        return dayOffsets.enumerated().compactMap { index, offset in
            guard let createdAt = calendar.date(byAdding: .day, value: -offset, to: now) else {
                return nil
            }

            let name = names[index % names.count]
            let job = jobs[index % jobs.count]
            let work = works[index % works.count]
            let isEmpreita = index % 3 == 0

            return Prestador(
                nome: name,
                servico: job,
                tipoRemuneracao: isEmpreita ? .empreita : .diaria,
                valorDiaria: isEmpreita ? nil : Decimal(220 + (index % 5) * 20),
                valorEmpreita: isEmpreita ? Decimal(3000 + (index % 4) * 700) : nil,
                prazoMaximoDias: isEmpreita ? (15 + (index % 5) * 5) : nil,
                dataFinalServico: isEmpreita ? calendar.date(byAdding: .day, value: 20 + index, to: createdAt) : nil,
                localServico: .obra(work),
                criadoEm: createdAt
            )
        }
    }
}
