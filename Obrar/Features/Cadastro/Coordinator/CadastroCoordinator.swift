import SwiftUI

struct CadastroCoordinator {
    func makeCadastroView() -> some View {
        let viewModel = CadastroViewModel()
        return CadastroView(viewModel: viewModel)
    }
}
