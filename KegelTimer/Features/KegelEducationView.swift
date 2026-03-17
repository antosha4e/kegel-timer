import SwiftUI

struct KegelEducationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var screen: EducationScreen = .overview
    @State private var methodIndex = 0

    var body: some View {
        ZStack {
            AppTheme.canvasGradient
                .ignoresSafeArea()

            backgroundGlow

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var topBar: some View {
        HStack {
            if screen != .overview {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.ink)
                        .frame(width: 46, height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppTheme.panel.opacity(0.94))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 46, height: 46)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.panel.opacity(0.94))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .overview:
            overviewScreen
        case .benefits:
            benefitsScreen
        case .howTo:
            howToScreen
        case .methods:
            methodsScreen
        case .eligibility:
            eligibilityScreen
        }
    }

    private var overviewScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                educationCard(
                    title: "What’s Kegel?",
                    eyebrow: "Pelvic Floor Guide",
                    body: [
                        "Kegel is a form of exercise. It strengthens your pelvic floor muscles that support and control your bladder to prevent or control urinary incontinence.",
                        "Kegel exercises have proven to help men last longer in bed. They strengthen pelvic floor muscles to help improve sexual performance."
                    ],
                    artwork: {
                        symbolArtwork(systemName: "figure.mind.and.body", palette: [AppTheme.accent.opacity(0.9), .white.opacity(0.18)])
                    }
                )

                VStack(spacing: 16) {
                    educationAction(title: "What are the benefits?") {
                        screen = .benefits
                    }

                    educationAction(title: "How to do Kegel?") {
                        screen = .howTo
                    }

                    educationAction(title: "Can I do Kegel?") {
                        screen = .eligibility
                    }
                }

                medicalNote
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    private var benefitsScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                educationCard(
                    title: "What are the benefits?",
                    eyebrow: "Why People Practice",
                    body: [],
                    artwork: {
                        symbolArtwork(systemName: "heart.text.square.fill", palette: [AppTheme.accent.opacity(0.88), .white.opacity(0.16)])
                    }
                )

                infoPanel(
                    title: "Sex Life",
                    items: [
                        "Help with erectile dysfunction.",
                        "Get more intense orgasms.",
                        "Last longer in bed."
                    ]
                )

                infoPanel(
                    title: "Privacy",
                    items: [
                        "You can do it anytime, anywhere. No one will know you are doing it."
                    ]
                )

                infoPanel(
                    title: "Self-care",
                    items: [
                        "Prevent and reduce prostatitis.",
                        "Reduce urinary urgency and frequency.",
                        "Improve the symptoms of post micturition dribble.",
                        "Improve bladder and bowel control."
                    ]
                )

                educationAction(title: "Got it") {
                    screen = .overview
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    private var howToScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                educationCard(
                    title: "How to do Kegel?",
                    eyebrow: "Technique",
                    body: [
                        "Kegel requires a rhythmic contraction of pelvic floor muscles to strengthen these muscles."
                    ],
                    artwork: {
                        symbolArtwork(systemName: "lungs.fill", palette: [AppTheme.accent.opacity(0.9), .white.opacity(0.14)])
                    }
                )

                infoPanel(
                    title: "Before You Start",
                    items: [
                        "Do not tense your buttocks, legs and abdomen.",
                        "Breathe normally while you contract and relax.",
                        "Release fully before starting the next repetition."
                    ]
                )

                educationAction(title: "How to find pelvic floor muscles?") {
                    methodIndex = 0
                    screen = .methods
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    private var methodsScreen: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 8)

            educationCard(
                title: methodPages[methodIndex].title,
                eyebrow: "Find The Right Muscles",
                body: [methodPages[methodIndex].text],
                artwork: {
                    symbolArtwork(
                        systemName: methodPages[methodIndex].symbol,
                        palette: [AppTheme.accent.opacity(0.94), .white.opacity(0.14)]
                    )
                }
            )
            .padding(.horizontal, 22)

            HStack(spacing: 10) {
                ForEach(Array(methodPages.indices), id: \.self) { index in
                    Capsule()
                        .fill(index == methodIndex ? AppTheme.accent : .white.opacity(0.16))
                        .frame(width: index == methodIndex ? 26 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: methodIndex)
                }
            }

            Spacer()

            educationAction(title: methodIndex == methodPages.count - 1 ? "Can I do Kegel?" : "Next") {
                if methodIndex == methodPages.count - 1 {
                    screen = .eligibility
                } else {
                    methodIndex += 1
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 28)
        }
    }

    private var eligibilityScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                educationCard(
                    title: "Can I do Kegel?",
                    eyebrow: "Who It Helps",
                    body: [
                        "You can benefit from Kegel exercises if you:",
                        "Experience erectile dysfunction, frequent or urgent urination, suffer the symptoms of prostatitis, or dribble after urination."
                    ],
                    artwork: {
                        symbolArtwork(systemName: "checkmark.seal.fill", palette: [AppTheme.accent.opacity(0.9), .white.opacity(0.18)])
                    }
                )

                infoPanel(
                    title: "Possible Reasons To Try",
                    items: [
                        "Experience erectile dysfunction.",
                        "Have frequent or urgent urination.",
                        "Suffer the symptoms of prostatitis.",
                        "Dribble after urination."
                    ]
                )

                infoPanel(
                    title: "Pause And Ask For Help If",
                    items: [
                        "You have pelvic pain or symptoms get worse while practicing.",
                        "You cannot tell whether you are contracting the right muscles.",
                        "You are recovering from surgery and do not yet have clearance."
                    ]
                )

                educationAction(title: "Got it") {
                    screen = .overview
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
    }

    private func educationCard<Artwork: View>(
        title: String,
        eyebrow: String,
        body: [String],
        @ViewBuilder artwork: () -> Artwork
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(eyebrow.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(AppTheme.mutedInk)

            Text(title)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            if !body.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(body, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.mutedInk.opacity(0.96))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            HStack {
                Spacer()
                artwork()
                Spacer()
            }
            .padding(.top, 10)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(AppTheme.panel.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func infoPanel(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 8, height: 8)
                        .padding(.top, 8)

                    Text(item)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.mutedInk.opacity(0.96))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.panelSecondary.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func educationAction(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppTheme.squeezeGradient)
                )
        }
        .buttonStyle(.plain)
    }

    private func symbolArtwork(systemName: String, palette: [Color]) -> some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 16)

            Image(systemName: systemName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(palette[0], palette[1])
                .font(.system(size: 82, weight: .medium))
        }
        .frame(height: 170)
    }

    private var backgroundGlow: some View {
        VStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.accent.opacity(0.16),
                            .clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 240
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 24)
                .offset(y: -120)

            Spacer()
        }
    }

    private var medicalNote: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.accent)
                .padding(.top, 2)

            Text("This guide is educational only. If you have pelvic pain, recent surgery, worsening leakage, or you are unsure about technique, get guidance from a qualified clinician.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppTheme.panel.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func goBack() {
        switch screen {
        case .overview:
            break
        case .benefits, .howTo, .eligibility:
            screen = .overview
        case .methods:
            if methodIndex > 0 {
                methodIndex -= 1
            } else {
                screen = .howTo
            }
        }
    }

    private var methodPages: [MethodPage] {
        [
            MethodPage(
                title: "Method 1",
                text: "Muscles that can slow or stop the urination are pelvic floor muscles. Don’t tense your buttocks, legs and abdomen when stopping midstream.",
                symbol: "drop.fill"
            ),
            MethodPage(
                title: "Method 2",
                text: "Muscles that can prevent the passing of gas are pelvic floor muscles.",
                symbol: "wind"
            )
        ]
    }
}

private extension KegelEducationView {
    enum EducationScreen {
        case overview
        case benefits
        case howTo
        case methods
        case eligibility
    }

    struct MethodPage {
        let title: String
        let text: String
        let symbol: String
    }
}

#Preview {
    KegelEducationView()
}
