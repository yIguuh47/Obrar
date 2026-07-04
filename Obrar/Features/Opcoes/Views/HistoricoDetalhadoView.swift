import SwiftUI

struct HistoricoDetalhadoView: View {
    @ObservedObject var viewModel: HistoricoDetalhadoViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Histórico Detalhado")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                if viewModel.dias.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.dias) { dia in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(dia.dataLabel)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textSecondary)

                                VStack(spacing: 8) {
                                    ForEach(dia.entries) { entry in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.prestadorNome)
                                                    .font(.body.weight(.semibold))
                                                    .foregroundStyle(AppColors.textPrimary)
                                                Text(entry.obraNome)
                                                    .font(.caption)
                                                    .foregroundStyle(AppColors.textTertiary)
                                            }
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(AppColors.backgroundElevated)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    }
                                }
                            }
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
            Text("Nenhum histórico disponível.")
                .foregroundStyle(AppColors.textPrimary)
            Text("Registre presença de prestadores para visualizar o histórico.")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    HistoricoDetalhadoView(viewModel: HistoricoDetalhadoViewModel())
        .preferredColorScheme(.dark)
}
