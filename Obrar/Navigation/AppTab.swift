enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case cadastro = "Cadastro"
    case opcoes = "Opções"

    var id: String { rawValue }
}
