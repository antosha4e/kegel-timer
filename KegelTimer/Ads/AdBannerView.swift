import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

private enum AdsLayout {
    static let reservedBannerHeight: CGFloat = 100
}

struct CompletionBannerAdView: View {
    let adUnitID: String

    var body: some View {
        GeometryReader { proxy in
            BannerContainer(adUnitID: adUnitID, availableWidth: proxy.size.width)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: AdsLayout.reservedBannerHeight)
        .clipped()
    }
}

#if canImport(GoogleMobileAds)
private struct BannerContainer: UIViewRepresentable {
    let adUnitID: String
    let availableWidth: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.clipsToBounds = true

        let bannerView = context.coordinator.bannerView
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.activeRootViewController

        containerView.addSubview(bannerView)

        context.coordinator.widthConstraint = bannerView.widthAnchor.constraint(equalToConstant: adSize.size.width)
        context.coordinator.heightConstraint = bannerView.heightAnchor.constraint(equalToConstant: adSize.size.height)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bannerView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            context.coordinator.widthConstraint,
            context.coordinator.heightConstraint
        ])

        context.coordinator.lastLoadedWidth = adSize.size.width
        bannerView.load(Request())
        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        let bannerView = context.coordinator.bannerView
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.activeRootViewController

        let nextAdSize = adSize
        context.coordinator.widthConstraint.constant = nextAdSize.size.width
        context.coordinator.heightConstraint.constant = nextAdSize.size.height

        if context.coordinator.lastLoadedWidth != nextAdSize.size.width {
            context.coordinator.lastLoadedWidth = nextAdSize.size.width
            bannerView.adSize = nextAdSize
            bannerView.load(Request())
        }
    }

    private var adSize: AdSize {
        let width = max(min(availableWidth, 600), 320)
        return currentOrientationAnchoredAdaptiveBanner(width: width)
    }

    @MainActor
    final class Coordinator {
        let bannerView = BannerView()
        var widthConstraint: NSLayoutConstraint!
        var heightConstraint: NSLayoutConstraint!
        var lastLoadedWidth: CGFloat = .zero
    }
}

private extension UIApplication {
    var activeRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}
#else
private struct BannerContainer: View {
    let adUnitID: String
    let availableWidth: CGFloat

    var body: some View {
        Color.clear
    }
}
#endif
