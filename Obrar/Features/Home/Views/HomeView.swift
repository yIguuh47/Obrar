import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HomeDateTabbarView(viewModel: viewModel)

            HomeWorkersListView(
                title: viewModel.workersSectionTitle,
                workers: viewModel.assignedWorkers,
                isEmpty: viewModel.isWorkersListEmpty,
                onAddWorkersTap: viewModel.addRegisteredWorkers
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .safeAreaPadding(.top, 8)
        .safeAreaPadding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.backgroundPrimary)
        .onAppear {
            viewModel.refreshWorkers()
        }
    }
}

#Preview {
    AppCoordinatorView()
        .preferredColorScheme(.dark)
}
