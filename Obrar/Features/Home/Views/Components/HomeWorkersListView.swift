import SwiftUI

struct HomeWorkersListView: View {
    let title: String
    let emptyStateTitle: String
    let emptyStateDescription: String
    let selectedPeriod: HomeViewModel.Period
    let groupedWorkersByDay: [HomeViewModel.WorkersDayGroup]
    let workers: [String]
    let isEmpty: Bool
    let onAddWorkersTap: () -> Void
    let onOpenDayGroup: (Date) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            if isEmpty {
                emptyStateCard
                    .frame(maxHeight: .infinity)
            } else {
                if selectedPeriod == .day {
                    workersList
                } else {
                    groupedWorkersList
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var workersList: some View {
        VStack(spacing: 8) {
            Button(action: onAddWorkersTap) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline.weight(.semibold))
                    Text("Registrar / Editar presença")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            ForEach(workers, id: \.self) { worker in
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(worker)
                        .font(.body.weight(.medium))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(16)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var groupedWorkersList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(groupedWorkersByDay) { group in
                    Button {
                        onOpenDayGroup(group.date)
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text(group.label)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColors.textSecondary)

                                Spacer()

                                Image(systemName: "square.and.pencil")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                            }

                            VStack(spacing: 8) {
                                if group.workers.isEmpty {
                                    HStack {
                                        Image(systemName: "person.slash")
                                            .foregroundStyle(AppColors.textTertiary)
                                        Text("Nenhum prestador neste dia.")
                                            .font(.body)
                                            .foregroundStyle(AppColors.textSecondary)
                                        Spacer()
                                    }
                                } else {
                                    ForEach(group.workers, id: \.self) { worker in
                                        HStack {
                                            Image(systemName: "person.fill")
                                                .foregroundStyle(AppColors.textTertiary)
                                            Text(worker)
                                                .font(.body.weight(.medium))
                                                .foregroundStyle(AppColors.textPrimary)
                                            Spacer()
                                        }
                                    }
                                }
                            }
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

                Text(emptyStateTitle)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.textPrimary)

                Text(emptyStateDescription)
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
        emptyStateTitle: "Nenhum prestador alocado para hoje.",
        emptyStateDescription: "Toque no botão abaixo para selecionar os prestadores cadastrados que trabalharam.",
        selectedPeriod: .day,
        groupedWorkersByDay: [],
        workers: [],
        isEmpty: true,
        onAddWorkersTap: {},
        onOpenDayGroup: { _ in }
    )
    .padding()
    .background(AppColors.backgroundPrimary)
    .preferredColorScheme(.dark)
}
