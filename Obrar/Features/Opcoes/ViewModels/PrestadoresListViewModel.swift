import Combine
import Foundation

final class PrestadoresListViewModel: ObservableObject {
    struct PrestadorItem: Identifiable {
        let id: UUID
        let nome: String
        let servico: String
        let local: String
    }

    @Published private(set) var prestadores: [PrestadorItem] = []

    private let prestadorStore: PrestadorStoreProtocol

    init(prestadorStore: PrestadorStoreProtocol = UserDefaultsPrestadorStore()) {
        self.prestadorStore = prestadorStore
        refresh()
    }

    func refresh() {
        do {
            let all = try prestadorStore.fetchAll()
            prestadores = all
                .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
                .map { prestador in
                    PrestadorItem(
                        id: prestador.id,
                        nome: prestador.nome,
                        servico: prestador.servico,
                        local: localDescription(for: prestador.localServico)
                    )
                }
        } catch {
            prestadores = []
        }
    }

    private func localDescription(for localServico: Prestador.LocalServico) -> String {
        switch localServico {
        case .obra(let obra):
            return obra
        case .localizacao(let local):
            return local
        }
    }
}
