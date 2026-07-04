import SwiftUI

struct PrestadoresListView: View {
    @ObservedObject var viewModel: PrestadoresListViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Prestadores")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                if viewModel.prestadores.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.prestadores) { prestador in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(prestador.nome)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                Text(prestador.servico)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(AppColors.textSecondary)

                                Text(prestador.local)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(AppColors.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
            .padding()
        }
        .safeAreaPadding(.top, 8)
        .safeAreaPadding(.bottom, 24)
        .background(AppColors.backgroundPrimary)
        .onAppear {
            viewModel.refresh()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Nenhum prestador cadastrado.")
                .foregroundStyle(AppColors.textPrimary)
            Text("Cadastre prestadores na aba Cadastro.")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PrestadoresListView(viewModel: PrestadoresListViewModel())
        .preferredColorScheme(.dark)
}
