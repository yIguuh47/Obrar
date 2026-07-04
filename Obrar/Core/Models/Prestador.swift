import Foundation

struct Prestador: Identifiable, Codable {
    enum TipoRemuneracao: String, Codable {
        case diaria
        case empreita
    }

    enum LocalServico: Codable {
        case obra(String)
        case localizacao(String)
    }

    let id: UUID
    let nome: String
    let servico: String
    let tipoRemuneracao: TipoRemuneracao
    let valorDiaria: Decimal?
    let valorEmpreita: Decimal?
    let prazoMaximoDias: Int?
    let dataFinalServico: Date?
    let localServico: LocalServico
    let criadoEm: Date

    init(
        id: UUID = UUID(),
        nome: String,
        servico: String,
        tipoRemuneracao: TipoRemuneracao,
        valorDiaria: Decimal?,
        valorEmpreita: Decimal?,
        prazoMaximoDias: Int?,
        dataFinalServico: Date?,
        localServico: LocalServico,
        criadoEm: Date = Date()
    ) {
        self.id = id
        self.nome = nome
        self.servico = servico
        self.tipoRemuneracao = tipoRemuneracao
        self.valorDiaria = valorDiaria
        self.valorEmpreita = valorEmpreita
        self.prazoMaximoDias = prazoMaximoDias
        self.dataFinalServico = dataFinalServico
        self.localServico = localServico
        self.criadoEm = criadoEm
    }
}
