import SwiftUI

struct HomeWorkersListView: View {
    let title: String
    let isEmpty: Bool
    let onAddWorkersTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            if isEmpty {
                emptyStateCard
            }
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(AppColors.textTertiary)

                Circle()
                    .fill(AppColors.surfaceSecondary)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(appIcon: .plus)
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                    )
                    .offset(x: 18, y: 18)
            }
            .padding(.top, 10)

            Text("Nenhum prestador alocado para hoje.")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textPrimary)

            Text("Toque no botão abaixo para selecionar os prestadores cadastrados que trabalharam.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)

            Button(action: onAddWorkersTap) {
                Text("+ Adicionar Prestadores Cadastrados")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    HomeWorkersListView(
        title: "Prestadores de Hoje",
        isEmpty: true,
        onAddWorkersTap: {}
    )
    .padding()
    .background(AppColors.backgroundPrimary)
    .preferredColorScheme(.dark)
}
