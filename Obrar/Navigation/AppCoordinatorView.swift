import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        VStack(spacing: 0) {
            NavigationStack(path: $coordinator.path) {
                coordinator.buildSelectedTab()
                    .navigationDestination(for: AppRoute.self) { route in
                        coordinator.build(route)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AppBottomTabBarView(
                selectedTab: coordinator.selectedTab,
                onSelect: coordinator.selectTab
            )
        }
        .background(AppColors.backgroundPrimary)
    }
}

#Preview {
    AppCoordinatorView()
}
