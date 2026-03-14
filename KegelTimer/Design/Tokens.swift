import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.93, green: 0.55, blue: 0.26)
    static let ink = Color(red: 0.18, green: 0.14, blue: 0.12)
    static let canvas = Color(red: 0.98, green: 0.95, blue: 0.9)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.8, blue: 0.55),
            Color(red: 0.94, green: 0.58, blue: 0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let canvasGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.96, blue: 0.92),
            Color(red: 0.95, green: 0.89, blue: 0.82)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let squeezeGradient = LinearGradient(
        colors: [
            Color(red: 0.91, green: 0.44, blue: 0.34),
            Color(red: 0.63, green: 0.17, blue: 0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let relaxGradient = LinearGradient(
        colors: [
            Color(red: 0.3, green: 0.61, blue: 0.61),
            Color(red: 0.17, green: 0.32, blue: 0.45)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
