import SwiftUI

enum AppIcon: String {
    // Navigation
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case arrowLeft = "arrow.left"
    case arrowRight = "arrow.right"

    // Tab bar
    case home = "house.fill"
    case folders = "folder.fill"
    case wallet = "wallet.pass.fill"
    case profile = "person.crop.circle.fill"

    // Actions
    case plus = "plus"
    case minus = "minus"
    case search = "magnifyingglass"
    case filter = "line.3.horizontal.decrease.circle"
    case calendar = "calendar"
    case bell = "bell.fill"
    case settings = "gearshape.fill"
    case check = "checkmark.circle.fill"
    case close = "xmark.circle.fill"
    case info = "info.circle.fill"
    case warning = "exclamationmark.triangle.fill"
}

extension Image {
    init(appIcon: AppIcon) {
        self.init(systemName: appIcon.rawValue)
    }
}
