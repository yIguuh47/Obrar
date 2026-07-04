import SwiftUI

struct OpcoesView: View {
    @ObservedObject var viewModel: OpcoesViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Opções")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 8) {
                    Image(appIcon: .search)
                        .foregroundStyle(AppColors.textTertiary)

                    TextField("Buscar opção", text: $viewModel.buscaTexto)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .foregroundStyle(AppColors.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(spacing: 0) {
                    ForEach(viewModel.opcoesFiltradas) { opcao in
                        NavigationLink(value: opcao.rota) {
                            HStack {
                                Text(opcao.titulo)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()

                                Image(appIcon: .chevronRight)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if opcao.id != viewModel.opcoesFiltradas.last?.id {
                            Rectangle()
                                .fill(AppColors.borderSubtle)
                                .frame(height: 1)
                        }
                    }
                }
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if viewModel.opcoesFiltradas.isEmpty {
                    Text("Nenhuma opção encontrada.")
                        .font(.footnote)
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary)
    }
}

#Preview {
    OpcoesView(viewModel: OpcoesViewModel())
        .preferredColorScheme(.dark)
}
