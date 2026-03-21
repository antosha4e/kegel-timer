import Foundation

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

enum AdsConfiguration {
    // Replace these sample IDs with production values before App Store release.
    static let admobAppID = "ca-app-pub-3940256099942544~1458002511"
    static let completionBannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
}

@MainActor
final class AdsManager {
    private var hasStarted = false

    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true

        #if canImport(GoogleMobileAds)
        MobileAds.shared.start()
        #endif
    }

    var completionBannerAdUnitID: String {
        AdsConfiguration.completionBannerAdUnitID
    }
}
