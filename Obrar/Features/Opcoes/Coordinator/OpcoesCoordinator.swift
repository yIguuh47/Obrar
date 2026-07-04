import SwiftUI

struct OpcoesCoordinator {
    func makeOpcoesView() -> some View {
        let viewModel = OpcoesViewModel()
        return OpcoesView(viewModel: viewModel)
    }
}
