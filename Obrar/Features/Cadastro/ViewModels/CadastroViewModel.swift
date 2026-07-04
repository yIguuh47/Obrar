import Combine
import Foundation

final class CadastroViewModel: ObservableObject {
    struct ObraCadastrada: Identifiable, Equatable {
        let id: String
        let nome: String
        let endereco: String

        init(id: String = UUID().uuidString, nome: String, endereco: String = "") {
            self.id = id
            self.nome = nome
            self.endereco = endereco
        }
    }

    enum TipoRemuneracao: String, CaseIterable, Identifiable {
        case diaria = "Diária"
        case empreita = "Empreita"

        var id: String { rawValue }
    }

    enum OrigemLocalServico: String, CaseIterable, Identifiable {
        case obraCadastrada = "Obra cadastrada"
        case cadastrarObra = "Cadastrar obra"

        var id: String { rawValue }
    }

    @Published var nome: String = ""
    @Published var servico: String = ""
    @Published var tipoRemuneracao: TipoRemuneracao = .diaria
    @Published var origemLocalServico: OrigemLocalServico = .obraCadastrada
    @Published var obraSelecionadaId: String = ""
    @Published var novaObraNome: String = ""
    @Published var novaObraEndereco: String = ""

    @Published var valorDiaria: String = ""
    @Published var valorEmpreita: String = ""
    @Published var prazoMaximoDias: String = ""
    @Published var dataFinalServico: Date = Date()
    @Published var showSaveAlert: Bool = false
    @Published private(set) var saveAlertMessage: String = ""

    @Published var obrasCadastradas: [ObraCadastrada] = [
        ObraCadastrada(nome: "Residencial Primavera"),
        ObraCadastrada(nome: "Reforma Apartamento Centro"),
        ObraCadastrada(nome: "Obra Comercial - Loja 12")
    ]

    private let prestadorStore: PrestadorStoreProtocol

    init(prestadorStore: PrestadorStoreProtocol = UserDefaultsPrestadorStore()) {
        self.prestadorStore = prestadorStore
        self.obraSelecionadaId = obrasCadastradas.first?.id ?? ""
    }

    var isEmpreita: Bool {
        tipoRemuneracao == .empreita
    }

    var isUsingRegisteredWork: Bool {
        origemLocalServico == .obraCadastrada
    }

    var obraSelecionadaAtual: ObraCadastrada? {
        obrasCadastradas.first { $0.id == obraSelecionadaId }
    }

    var isSaveEnabled: Bool {
        let nomeValido = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let servicoValido = !servico.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let localValido = isUsingRegisteredWork
            ? obraSelecionadaAtual != nil
            : !novaObraNome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if isEmpreita {
            return nomeValido &&
                servicoValido &&
                localValido &&
                parseCurrency(valorEmpreita) != nil &&
                Int(prazoMaximoDias) != nil
        }

        return nomeValido &&
            servicoValido &&
            localValido &&
            parseCurrency(valorDiaria) != nil
    }

    func salvarPrestador() {
        guard isSaveEnabled else {
            saveAlertMessage = "Preencha todos os campos obrigatórios para salvar."
            showSaveAlert = true
            return
        }

        if !isUsingRegisteredWork {
            guard cadastrarNovaObra(showAlertOnFailure: true) else {
                return
            }
        }

        let localServico: Prestador.LocalServico = isUsingRegisteredWork
            ? .obra(descricaoObraSelecionada())
            : .obra(descricaoObraSelecionada())

        let prestador = Prestador(
            nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
            servico: servico.trimmingCharacters(in: .whitespacesAndNewlines),
            tipoRemuneracao: isEmpreita ? .empreita : .diaria,
            valorDiaria: isEmpreita ? nil : parseCurrency(valorDiaria),
            valorEmpreita: isEmpreita ? parseCurrency(valorEmpreita) : nil,
            prazoMaximoDias: isEmpreita ? Int(prazoMaximoDias) : nil,
            dataFinalServico: isEmpreita ? dataFinalServico : nil,
            localServico: localServico
        )

        do {
            try prestadorStore.save(prestador)
            resetForm(keepingSelectedWorkId: obraSelecionadaId)
            saveAlertMessage = "Prestador salvo com sucesso."
        } catch {
            saveAlertMessage = "Não foi possível salvar agora. Tente novamente."
        }

        showSaveAlert = true
    }

    func cadastrarNovaObra() {
        _ = cadastrarNovaObra(showAlertOnFailure: true)
    }

    @discardableResult
    private func cadastrarNovaObra(showAlertOnFailure: Bool) -> Bool {
        let nomeTratado = novaObraNome.trimmingCharacters(in: .whitespacesAndNewlines)
        let enderecoTratado = novaObraEndereco.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nomeTratado.isEmpty else {
            if showAlertOnFailure {
                saveAlertMessage = "Digite o nome da obra para cadastrar."
                showSaveAlert = true
            }
            return false
        }

        let obraJaExiste = obrasCadastradas.contains {
            $0.nome.caseInsensitiveCompare(nomeTratado) == .orderedSame
        }

        guard !obraJaExiste else {
            if let obraExistente = obrasCadastradas.first(where: { $0.nome.caseInsensitiveCompare(nomeTratado) == .orderedSame }) {
                obraSelecionadaId = obraExistente.id
                origemLocalServico = .obraCadastrada
            }

            if showAlertOnFailure {
                saveAlertMessage = "Essa obra já está cadastrada."
                showSaveAlert = true
            }
            return false
        }

        let novaObra = ObraCadastrada(nome: nomeTratado, endereco: enderecoTratado)
        obrasCadastradas.append(novaObra)
        obraSelecionadaId = novaObra.id
        origemLocalServico = .obraCadastrada
        novaObraNome = ""
        novaObraEndereco = ""
        return true
    }

    private func descricaoObraSelecionada() -> String {
        guard let obra = obraSelecionadaAtual else {
            return ""
        }

        let endereco = obra.endereco.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !endereco.isEmpty else {
            return obra.nome
        }

        return "\(obra.nome) - \(endereco)"
    }

    private func parseCurrency(_ value: String) -> Decimal? {
        let cleanValue = value
            .replacingOccurrences(of: "R$", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Decimal(string: cleanValue)
    }

    private func resetForm(keepingSelectedWorkId selectedWorkId: String? = nil) {
        nome = ""
        servico = ""
        origemLocalServico = .obraCadastrada
        if let selectedWorkId,
           obrasCadastradas.contains(where: { $0.id == selectedWorkId }) {
            obraSelecionadaId = selectedWorkId
        } else {
            obraSelecionadaId = obrasCadastradas.first?.id ?? ""
        }
        novaObraNome = ""
        novaObraEndereco = ""
        tipoRemuneracao = .diaria
        valorDiaria = ""
        valorEmpreita = ""
        prazoMaximoDias = ""
        dataFinalServico = Date()
    }
}
