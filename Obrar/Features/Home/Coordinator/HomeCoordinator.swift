import SwiftUI

struct HomeCoordinator {
    func makeHomeView(onRequestOpenCadastro: (() -> Void)? = nil) -> some View {
        let viewModel = HomeViewModel()
        viewModel.onRequestOpenCadastro = onRequestOpenCadastro
        return HomeView(viewModel: viewModel)
    }
}
