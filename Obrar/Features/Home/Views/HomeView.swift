import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HomeDateTabbarView(viewModel: viewModel)

            HomeWorkersListView(
                title: viewModel.workersSectionTitle,
                emptyStateTitle: viewModel.emptyStateTitle,
                emptyStateDescription: viewModel.emptyStateDescription,
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
        .sheet(isPresented: $viewModel.showWorkersSelectionSheet) {
            HomeWorkersSelectionSheetView(
                title: viewModel.workersSelectionTitle,
                workers: viewModel.availableWorkers,
                isSelected: viewModel.isWorkerSelected,
                onToggle: viewModel.toggleWorkerSelection,
                subtitleForWorker: { worker in
                    viewModel.workName(from: worker.localServico)
                },
                onSave: viewModel.saveSelectedWorkersForReferenceDate
            )
        }
    }
}

#Preview {
    AppCoordinatorView()
        .preferredColorScheme(.dark)
}
