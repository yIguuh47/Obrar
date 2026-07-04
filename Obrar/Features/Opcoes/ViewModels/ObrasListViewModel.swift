import Combine
import Foundation

final class ObrasListViewModel: ObservableObject {
    @Published private(set) var obras: [Obra] = []

    private let obraStore: ObraStoreProtocol

    init(obraStore: ObraStoreProtocol = UserDefaultsObraStore()) {
        self.obraStore = obraStore
        refresh()
    }

    func refresh() {
        do {
            obras = try obraStore.fetchAll()
                .sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
        } catch {
            obras = []
        }
    }
}
