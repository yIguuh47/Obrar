import Foundation

protocol PrestadorStoreProtocol {
    func fetchAll() throws -> [Prestador]
    func save(_ prestador: Prestador) throws
}

final class UserDefaultsPrestadorStore: PrestadorStoreProtocol {
    private let key = "obrar.prestadores"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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
}
