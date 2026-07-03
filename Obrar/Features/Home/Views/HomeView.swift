import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HomeDateTabbarView(viewModel: viewModel)

            HomeWorkersListView(
                title: viewModel.workersSectionTitle,
                isEmpty: viewModel.isWorkersListEmpty,
                onAddWorkersTap: viewModel.addRegisteredWorkers
            )

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.backgroundPrimary)
    }
}

#Preview {
    AppCoordinatorView()
        .preferredColorScheme(.dark)
}
