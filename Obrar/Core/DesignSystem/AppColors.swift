import SwiftUI

enum AppColors {
    // MARK: - Background
    static let backgroundPrimary = Color.black
    static let backgroundSecondary = Color(red: 0.09, green: 0.09, blue: 0.1)
    static let backgroundElevated = Color(red: 0.12, green: 0.12, blue: 0.14)

    // MARK: - Surface
    static let surfacePrimary = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let surfaceSecondary = Color(red: 0.2, green: 0.2, blue: 0.22)
    static let surfaceDisabled = Color(red: 0.25, green: 0.25, blue: 0.27)

    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.78)
    static let textTertiary = Color(white: 0.58)
    static let textDisabled = Color(white: 0.45)

    // MARK: - Accent
    static let accentPrimary = Color.orange
    static let accentPressed = Color(red: 0.88, green: 0.44, blue: 0.0)

    // MARK: - States
    static let success = Color.green
    static let warning = Color.yellow
    static let danger = Color.red

    // MARK: - Border
    static let borderSubtle = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.18)
}
