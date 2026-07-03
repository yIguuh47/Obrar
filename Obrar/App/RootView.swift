import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            AppCoordinatorView()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
