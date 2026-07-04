import SwiftUI

struct CadastroView: View {
    @ObservedObject var viewModel: CadastroViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cadastro de Prestador")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)

                sectionCard(title: "Dados do Prestador") {
                    inputField(title: "Nome", text: $viewModel.nome, placeholder: "Nome completo")
                    divider
                    inputField(title: "Serviço", text: $viewModel.servico, placeholder: "Ex.: Pedreiro")
                }

                sectionCard(title: "Obra / Localização") {
                    Picker("Origem", selection: $viewModel.origemLocalServico) {
                        ForEach(CadastroViewModel.OrigemLocalServico.allCases) { origem in
                            Text(origem.rawValue).tag(origem)
                        }
                    }
                    .pickerStyle(.segmented)

                    divider

                    if viewModel.isUsingRegisteredWork {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Obra cadastrada")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppColors.textSecondary)

                            Picker("Obra", selection: $viewModel.obraSelecionadaId) {
                                ForEach(viewModel.obrasCadastradas) { obra in
                                    Text(obra.nome).tag(obra.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.textPrimary)
                        }
                    } else {
                        inputField(
                            title: "Nome da nova obra",
                            text: $viewModel.novaObraNome,
                            placeholder: "Ex.: Obra Condomínio Jardim"
                        )

                        inputField(
                            title: "Endereço da obra (opcional)",
                            text: $viewModel.novaObraEndereco,
                            placeholder: "Ex.: Rua B, 245 - Setor Sul"
                        )

                        Button(action: viewModel.cadastrarNovaObra) {
                            Text("Cadastrar Obra")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(AppColors.accentPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }

                sectionCard(title: "Remuneração") {
                    Picker("Tipo", selection: $viewModel.tipoRemuneracao) {
                        ForEach(CadastroViewModel.TipoRemuneracao.allCases) { tipo in
                            Text(tipo.rawValue).tag(tipo)
                        }
                    }
                    .pickerStyle(.segmented)

                    divider

                    if viewModel.isEmpreita {
                        inputField(
                            title: "Valor total da empreita",
                            text: $viewModel.valorEmpreita,
                            placeholder: "R$ 0,00",
                            keyboardType: .decimalPad
                        )

                        divider

                        inputField(
                            title: "Prazo máximo (dias)",
                            text: $viewModel.prazoMaximoDias,
                            placeholder: "Ex.: 30",
                            keyboardType: .numberPad
                        )

                        divider

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data para finalizar o serviço")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppColors.textSecondary)

                            DatePicker(
                                "Data final",
                                selection: $viewModel.dataFinalServico,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "pt_BR"))
                            .tint(AppColors.accentPrimary)
                        }
                    } else {
                        inputField(
                            title: "Valor da diária",
                            text: $viewModel.valorDiaria,
                            placeholder: "R$ 0,00",
                            keyboardType: .decimalPad
                        )
                    }
                }

                Button(action: viewModel.salvarPrestador) {
                    Text("Salvar Prestador")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isSaveEnabled ? AppColors.accentPrimary : AppColors.surfaceDisabled)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(!viewModel.isSaveEnabled)
                .opacity(viewModel.isSaveEnabled ? 1 : 0.7)
            }
            .padding()
        }
        .safeAreaPadding(.top, 8)
        .safeAreaPadding(.bottom, 24)
        .background(AppColors.backgroundPrimary)
        .alert("Cadastro de Prestador", isPresented: $viewModel.showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.saveAlertMessage)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.borderSubtle)
            .frame(height: 1)
    }

    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
            content()
        }
        .padding(16)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}

#Preview {
    CadastroView(viewModel: CadastroViewModel())
        .preferredColorScheme(.dark)
}
