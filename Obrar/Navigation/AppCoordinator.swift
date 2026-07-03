import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var selectedTab: AppTab = .home

    private let homeCoordinator = HomeCoordinator()

    @ViewBuilder
    func build(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            homeCoordinator.makeHomeView()
        }
    }

    @ViewBuilder
    func buildSelectedTab() -> some View {
        switch selectedTab {
        case .home:
            homeCoordinator.makeHomeView()
        case .cadastro:
            tabPlaceholder(
                title: "Cadastro",
                subtitle: "Área pronta para os fluxos de cadastro."
            )
        case .opcoes:
            tabPlaceholder(
                title: "Opções",
                subtitle: "Área pronta para configurações e preferências."
            )
        }
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    private func tabPlaceholder(title: String, subtitle: String) -> some View {
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
