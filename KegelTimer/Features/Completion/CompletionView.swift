import SwiftUI

struct CompletionView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var sessionEngine: SessionEngine

    var body: some View {
        ZStack(alignment: .bottom) {
            completionBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 48)

                HStack {
                    Spacer(minLength: 0)
                    completionCard
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            bottomDock
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
                .offset(x: 90, y: -232)

            cloudLayer(width: 300, height: 120, opacity: 0.28)
                .offset(x: -126, y: -286)
            cloudLayer(width: 240, height: 96, opacity: 0.2)
                .offset(x: 96, y: -224)
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

    private var completionCard: some View {
        VStack(spacing: 0) {
            completionBadge
                .padding(.top, 34)

            Text("Session Complete!")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("Take a break and come back later for another round.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .multilineTextAlignment(.center)
                .padding(.top, 18)
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
        }
        .frame(maxWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(.black.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
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

            Text("\(completedStages)/\(totalStages)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
    }

    private var bottomDock: some View {
        VStack(spacing: 12) {
            if appModel.shouldShowCompletionBanner {
                CompletionBannerAdView(adUnitID: appModel.completionBannerAdUnitID)
                    .padding(.horizontal, 30)
            }

            HStack {
                Spacer(minLength: 0)
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
                .frame(maxWidth: 520)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 30)
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
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

    private var completedStages: Int {
        min(sessionEngine.state?.currentStageIndex ?? totalStages, totalStages)
    }

    private var totalStages: Int {
        sessionEngine.state?.totalStages ?? appModel.program.stages.count
    }
}
