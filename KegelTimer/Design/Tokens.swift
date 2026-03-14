import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.96, green: 0.19, blue: 0.2)
    static let ink = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let mutedInk = Color(red: 0.54, green: 0.56, blue: 0.62)
    static let canvas = Color(red: 0.09, green: 0.1, blue: 0.13)
    static let canvasSecondary = Color(red: 0.12, green: 0.13, blue: 0.18)
    static let panel = Color(red: 0.08, green: 0.08, blue: 0.1)
    static let panelSecondary = Color(red: 0.14, green: 0.15, blue: 0.22)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.24, green: 0.13, blue: 0.16),
            Color(red: 0.1, green: 0.1, blue: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let canvasGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.07, blue: 0.09),
            Color(red: 0.13, green: 0.14, blue: 0.19)
        ],
        startPoint: .topLeading,
        endPoint: .bottom
    )

    static let squeezeGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.26, blue: 0.23),
            Color(red: 0.64, green: 0.07, blue: 0.13)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let relaxGradient = LinearGradient(
        colors: [
            Color(red: 0.52, green: 0.54, blue: 0.63),
            Color(red: 0.24, green: 0.27, blue: 0.36)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
