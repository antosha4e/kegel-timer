import SwiftUI

struct CompletionView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ZStack {
            completionBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 80)

                completionBadge

                Text("Session Complete!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 26)

                Text("Take a break and come back later for another round.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    .padding(.horizontal, 36)

                Spacer()

                Button {
                    appModel.finishCompletedSession()
                } label: {
                    Text("Continue")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(AppTheme.squeezeGradient)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var completionBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.17, blue: 0.25),
                    Color(red: 0.04, green: 0.06, blue: 0.1),
                    Color(red: 0.03, green: 0.03, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            moonGlow
                .offset(x: 118, y: -232)

            cloudLayer(width: 300, height: 120, opacity: 0.28)
                .offset(x: -126, y: -286)
            cloudLayer(width: 240, height: 96, opacity: 0.2)
                .offset(x: 124, y: -224)
            mountainShape
                .fill(Color.black.opacity(0.55))
                .frame(width: 420, height: 360)
                .offset(y: -36)
            foregroundRidge
                .fill(Color.black.opacity(0.72))
                .frame(width: 430, height: 330)
                .offset(y: 44)
        }
    }

    private var completionBadge: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.mutedInk.opacity(0.55), lineWidth: 16)
                .frame(width: 124, height: 124)

            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    AppTheme.squeezeGradient,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 124, height: 124)
                .rotationEffect(.degrees(130))

            Text("1/1")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private var moonGlow: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: 140, height: 140)
                .blur(radius: 20)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white,
                            Color(red: 0.79, green: 0.88, blue: 1.0)
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 42
                    )
                )
                .frame(width: 88, height: 88)
        }
    }

    private func cloudLayer(width: CGFloat, height: CGFloat, opacity: Double) -> some View {
        Capsule()
            .fill(.white.opacity(opacity))
            .frame(width: width, height: height)
            .blur(radius: 24)
    }

    private var mountainShape: some Shape {
        UnevenRoundedRectangle(topLeadingRadius: 180, bottomLeadingRadius: 40, bottomTrailingRadius: 40, topTrailingRadius: 180)
    }

    private var foregroundRidge: some Shape {
        UnevenRoundedRectangle(topLeadingRadius: 140, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 160)
    }
}

#Preview {
    CompletionView()
        .environmentObject(AppModel())
}
