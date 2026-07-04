import SwiftUI

struct ObrasListView: View {
    @ObservedObject var viewModel: ObrasListViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Obras")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                if viewModel.obras.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.obras) { obra in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(obra.nome)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                if !obra.endereco.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text(obra.endereco)
                                        .font(.caption)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
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
            Text("Nenhuma obra cadastrada.")
                .foregroundStyle(AppColors.textPrimary)
            Text("Cadastre obras na aba Cadastro.")
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
    ObrasListView(viewModel: ObrasListViewModel())
        .preferredColorScheme(.dark)
}
