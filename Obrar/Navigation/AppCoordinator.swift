import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var path = NavigationPath()

    private let homeCoordinator = HomeCoordinator()

    @ViewBuilder
    func build(_ route: AppRoute) -> some View {
        switch route {
        case .home:
            homeCoordinator.makeHomeView()
        }
    }
}
