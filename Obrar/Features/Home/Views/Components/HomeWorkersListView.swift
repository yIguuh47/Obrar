import SwiftUI

struct HomeWorkersListView: View {
    let title: String
    let isEmpty: Bool
    let onAddWorkersTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            if isEmpty {
                emptyStateCard
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var emptyStateCard: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
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
                        .offset(x: 16, y: 16)
                }
                .padding(.top, 16)

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
                        .padding(.vertical, 16)
                        .background(AppColors.accentPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.top, 16)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
