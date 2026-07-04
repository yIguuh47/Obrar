import Combine
import Foundation

final class OpcoesViewModel: ObservableObject {
    struct OpcaoItem: Identifiable, Hashable {
        let id: AppRoute
        let titulo: String
        let rota: AppRoute
    }

    @Published var buscaTexto: String = ""

    private let opcoes: [OpcaoItem] = [
        .init(id: .obras, titulo: "Obras", rota: .obras),
        .init(id: .prestadores, titulo: "Prestadores", rota: .prestadores),
        .init(id: .historico, titulo: "Historico", rota: .historico),
        .init(id: .relatorios, titulo: "Relatorios", rota: .relatorios),
        .init(id: .orcamento, titulo: "Orcamento", rota: .orcamento)
    ]

    var opcoesFiltradas: [OpcaoItem] {
        let texto = buscaTexto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else {
            return opcoes
        }

        return opcoes.filter { opcao in
            opcao.titulo.localizedCaseInsensitiveContains(texto)
        }
    }
}
