import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var selectedTab: AppTab = .home

    private let homeCoordinator = HomeCoordinator()
    private let cadastroCoordinator = CadastroCoordinator()
    private let opcoesCoordinator = OpcoesCoordinator()

    @ViewBuilder
    func build(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            homeCoordinator.makeHomeView(onRequestOpenCadastro: { [weak self] in
                self?.selectTab(.cadastro)
            })
        case .obras:
            ObrasListView(viewModel: ObrasListViewModel())
        case .prestadores:
            PrestadoresListView(viewModel: PrestadoresListViewModel())
        case .historico:
            HistoricoDetalhadoView(viewModel: HistoricoDetalhadoViewModel())
        case .relatorios:
            destinationScreen(
                title: "Relatorios",
                subtitle: "Tela especifica de relatorios."
            )
        case .orcamento:
            destinationScreen(
                title: "Orcamento",
                subtitle: "Tela especifica de orcamento."
            )
        }
    }

    @ViewBuilder
    func buildSelectedTab() -> some View {
        switch selectedTab {
        case .home:
            homeCoordinator.makeHomeView(onRequestOpenCadastro: { [weak self] in
                self?.selectTab(.cadastro)
            })
        case .cadastro:
            cadastroCoordinator.makeCadastroView()
        case .opcoes:
            opcoesCoordinator.makeOpcoesView()
        }
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
        path = NavigationPath()
    }

    private func destinationScreen(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundPrimary)
    }
}
