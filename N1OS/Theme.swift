import SwiftUI

enum Theme {
    // MARK: - Frame Dimensions
    static let phoneWidth: CGFloat = 360
    static let phoneHeight: CGFloat = 754
    static let screenWidth: CGFloat = 316
    static let screenHeight: CGFloat = 632
    static let sideBezel: CGFloat = 22
    static let topBezel: CGFloat = 61
    static let bottomBezel: CGFloat = 61
    static let topPanelHeight: CGFloat = 26
    static let dockHeight: CGFloat = 52
    static let windowWidth: CGFloat = 300
    static let windowHeight: CGFloat = 310
    static let frameRadius: CGFloat = 32
    static let screenRadius: CGFloat = 16

    // MARK: - Colors
    static let bgPrimary = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let bgSecondary = Color(red: 0.09, green: 0.09, blue: 0.14)
    static let bgTertiary = Color(red: 0.12, green: 0.12, blue: 0.18)
    static let bgCard = Color(red: 0.10, green: 0.10, blue: 0.16)
    static let bgInput = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let bgHover = Color.white.opacity(0.05)

    static let textPrimary = Color(red: 0.93, green: 0.93, blue: 0.96)
    static let textSecondary = Color(red: 0.60, green: 0.60, blue: 0.68)
    static let textMuted = Color(red: 0.40, green: 0.40, blue: 0.48)

    static let accent = Color(red: 0.40, green: 0.83, blue: 1.0)
    static let accentDim = Color(red: 0.40, green: 0.83, blue: 1.0).opacity(0.3)
    static let success = Color(red: 0.20, green: 0.89, blue: 0.60)
    static let warning = Color(red: 1.0, green: 0.72, blue: 0.28)
    static let danger = Color(red: 1.0, green: 0.36, blue: 0.42)
    static let purple = Color(red: 0.65, green: 0.45, blue: 1.0)

    static let border = Color.white.opacity(0.08)
    static let borderLight = Color.white.opacity(0.12)

    static let bezelColor = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let earpiece = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let camera = Color(red: 0.10, green: 0.10, blue: 0.14)

    // MARK: - Window Header
    static let windowHeader = Color(red: 0.09, green: 0.09, blue: 0.14)
    static let windowBody = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let closeBtn = Color(red: 1.0, green: 0.36, blue: 0.42)
    static let minBtn = Color(red: 1.0, green: 0.72, blue: 0.28)
    static let maxBtn = Color(red: 0.20, green: 0.89, blue: 0.60)

    // MARK: - Typography
    static let fontMicro: CGFloat = 7
    static let fontTiny: CGFloat = 8
    static let fontSmall: CGFloat = 9
    static let fontBody: CGFloat = 10
    static let fontMedium: CGFloat = 11
    static let fontLarge: CGFloat = 13
    static let fontXL: CGFloat = 16
    static let fontXXL: CGFloat = 22

    // MARK: - Spacing
    static let spacingXS: CGFloat = 2
    static let spacingSM: CGFloat = 4
    static let spacingMD: CGFloat = 8
    static let spacingLG: CGFloat = 12
    static let spacingXL: CGFloat = 16

    // MARK: - Corner Radii
    static let radiusSmall: CGFloat = 4
    static let radiusMedium: CGFloat = 6
    static let radiusLarge: CGFloat = 8
    static let radiusXL: CGFloat = 12
}
