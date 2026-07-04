import Combine
import Foundation

final class HistoricoDetalhadoViewModel: ObservableObject {
    struct HistoricoDia: Identifiable {
        struct Entry: Identifiable {
            let id: UUID
            let prestadorNome: String
            let obraNome: String
        }

        let id: UUID
        let dataLabel: String
        let entries: [Entry]
    }

    @Published private(set) var dias: [HistoricoDia] = []

    private let registroStore: RegistroDiarioStoreProtocol
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter
    }()

    init(registroStore: RegistroDiarioStoreProtocol = UserDefaultsRegistroDiarioStore()) {
        self.registroStore = registroStore
        refresh()
    }

    func refresh() {
        do {
            let registros = try registroStore.fetchAll().sorted { $0.data > $1.data }
            dias = registros.map { registro in
                let entries = registro.itens.map { item in
                    HistoricoDia.Entry(
                        id: item.id,
                        prestadorNome: item.prestadorNome,
                        obraNome: item.obraNome
                    )
                }
                return HistoricoDia(
                    id: registro.id,
                    dataLabel: dayFormatter.string(from: registro.data).capitalized,
                    entries: entries
                )
            }
        } catch {
            dias = []
        }
    }
}
