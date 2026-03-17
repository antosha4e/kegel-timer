import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var isEducationPresented = false

    var body: some View {
        ZStack {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("Kegel Timer")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Text("Start a guided session")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Button {
                    isEducationPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 15, weight: .semibold))

                        Text("What is Kegel?")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.09))
                    )
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    appModel.beginSessionStartCountdown()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.squeezeGradient)
                            .frame(width: 200, height: 200)
                            .shadow(color: AppTheme.accent.opacity(0.35), radius: 28, y: 16)

                        Circle()
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                            .frame(width: 200, height: 200)

                        VStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 36, weight: .bold))
                            Text("Start")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)

                Text("Tap to begin")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.mutedInk)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accent.opacity(0.22),
                                .clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 230
                        )
                    )
                    .frame(width: 360, height: 360)
                    .blur(radius: 24)
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isEducationPresented) {
            KegelEducationView()
                .presentationDragIndicator(.visible)
        }
    }
}
