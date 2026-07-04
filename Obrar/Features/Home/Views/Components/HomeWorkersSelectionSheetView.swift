import SwiftUI

struct HomeWorkersSelectionSheetView: View {
    let title: String
    let workers: [Prestador]
    let isSelected: (UUID) -> Bool
    let onToggle: (UUID) -> Void
    let subtitleForWorker: (Prestador) -> String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if workers.isEmpty {
                    VStack(spacing: 8) {
                        Text("Nenhum prestador cadastrado.")
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Cadastre prestadores na aba Cadastro para poder alocar.")
                            .font(.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(workers) { worker in
                                Button {
                                    onToggle(worker.id)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: isSelected(worker.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(isSelected(worker.id) ? AppColors.accentPrimary : AppColors.textTertiary)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(worker.nome)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(AppColors.textPrimary)
                                            Text(subtitleForWorker(worker))
                                                .font(.caption)
                                                .foregroundStyle(AppColors.textSecondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(16)
                                    .background(AppColors.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Button(action: onSave) {
                    Text("Salvar seleção")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.accentPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding()
            .background(AppColors.backgroundPrimary)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    HomeWorkersSelectionSheetView(
        title: "Selecionar Prestadores",
        workers: [],
        isSelected: { _ in false },
        onToggle: { _ in },
        subtitleForWorker: { _ in "Obra" },
        onSave: {}
    )
}
