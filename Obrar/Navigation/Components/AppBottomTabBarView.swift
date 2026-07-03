import SwiftUI

struct AppBottomTabBarView: View {
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabButton(
                for: .home,
                icon: .home,
                label: "HOME"
            )

            centerTabButton

            tabButton(
                for: .opcoes,
                icon: .settings,
                label: "OPÇÕES"
            )
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(AppColors.backgroundSecondary)
        .overlay(alignment: .top) {
            AppColors.borderSubtle
                .frame(height: 1)
        }
    }

    private var centerTabButton: some View {
        Button {
            onSelect(.cadastro)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(AppColors.accentPrimary)
                        .frame(width: 34, height: 34)

                    Image(appIcon: .plus)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.black)
                }
                .offset(y: -6)

                Text("CADASTRO")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(color(for: .cadastro))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func tabButton(for tab: AppTab, icon: AppIcon, label: String) -> some View {
        Button {
            onSelect(tab)
        } label: {
            VStack(spacing: 4) {
                Image(appIcon: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color(for: tab))
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(color(for: tab))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func color(for tab: AppTab) -> Color {
        selectedTab == tab ? AppColors.accentPrimary : AppColors.textDisabled
    }
}

#Preview {
    AppBottomTabBarView(selectedTab: .home, onSelect: { _ in })
        .preferredColorScheme(.dark)
}
