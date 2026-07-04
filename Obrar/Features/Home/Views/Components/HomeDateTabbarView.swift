//
//  HomeDateTabbarView.swift
//  Obrar
//
//  Created by Igor Damasceno de Sousa on 03/07/26.
//

import SwiftUI

struct HomeDateTabbarView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: viewModel.goToPrevious) {
                    Image(appIcon: .chevronLeft)
                        .font(.headline)
                        .foregroundStyle(AppColors.accentPrimary)
                        .frame(width: 36, height: 36)
                }

                Spacer()

                Text(viewModel.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Button(action: viewModel.goToNext) {
                    Image(appIcon: .chevronRight)
                        .font(.headline)
                        .foregroundStyle(AppColors.accentPrimary)
                        .frame(width: 36, height: 36)
                }
            }

            Picker("Período", selection: $viewModel.selectedPeriod) {
                ForEach(HomeViewModel.Period.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    HomeDateTabbarView(viewModel: HomeViewModel())
        .preferredColorScheme(.dark)
}
