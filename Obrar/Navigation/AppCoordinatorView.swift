import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.buildSelectedTab()
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.build(route)
                }
        }
        .safeAreaInset(edge: .bottom) {
            AppBottomTabBarView(
                selectedTab: coordinator.selectedTab,
                onSelect: coordinator.selectTab
            )
        }
    }
}

#Preview {
    AppCoordinatorView()
}
