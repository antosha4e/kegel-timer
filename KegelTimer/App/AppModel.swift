import Combine
import SwiftUI

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published private(set) var startCountdownRemaining: TimeInterval?
    @Published private(set) var removeAdsProductPrice: String?
    @Published private(set) var isStoreProcessing = false
    @Published var alert: AppAlert?

    let sessionEngine: SessionEngine
    let adsManager: AdsManager
    let storeManager: StoreManager

    private let storage: AppStorage
    private let cueManager: CueManager
    private var cancellables = Set<AnyCancellable>()
    private var hasRestored = false
    private var countdownTask: Task<Void, Never>?

    init(
        storage: AppStorage = AppStorage(),
        cueManager: CueManager = CueManager(),
        adsManager: AdsManager? = nil,
        storeManager: StoreManager? = nil
    ) {
        self.storage = storage
        self.cueManager = cueManager
        self.adsManager = adsManager ?? AdsManager()
        self.storeManager = storeManager ?? StoreManager()
        self.settings = storage.loadSettings()
        self.sessionEngine = SessionEngine(cueManager: cueManager)

        self.storeManager.onEntitlementChange = { [weak self] hasRemovedAds in
            self?.setHasRemovedAds(hasRemovedAds)
        }
        self.storeManager.onProductChange = { [weak self] product in
            self?.removeAdsProductPrice = product?.displayPrice
        }

        sessionEngine.onSnapshotChange = { [weak self] snapshot in
            self?.storage.saveActiveSnapshot(snapshot)
        }

        sessionEngine.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyIdleTimerPolicy()
            }
            .store(in: &cancellables)
    }

    var program: WorkoutProgram {
        settings.difficulty.program
    }

    func restore() {
        guard !hasRestored else { return }
        hasRestored = true
        adsManager.startIfNeeded()
        storeManager.startIfNeeded()
        storage.saveActiveSnapshot(nil)
        sessionEngine.restore(from: nil, settings: settings)
        applyIdleTimerPolicy()
    }

    func startSession() {
        cancelStartCountdown()
        sessionEngine.start(program: program, settings: settings)
        applyIdleTimerPolicy()
    }

    func beginSessionStartCountdown() {
        guard startCountdownRemaining == nil, sessionEngine.state == nil else { return }
        let countdownDuration = configuredStartCountdownDuration

        guard countdownDuration > 0 else {
            startSession()
            return
        }

        startCountdownRemaining = countdownDuration
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            guard let self else { return }

            let startDate = Date()

            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startDate)
                let remaining = max(0, countdownDuration - elapsed)
                self.startCountdownRemaining = remaining

                if remaining <= 0 {
                    self.startCountdownRemaining = nil
                    self.startSession()
                    return
                }

                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    func cancelStartCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        startCountdownRemaining = nil
        applyIdleTimerPolicy()
    }

    var isStartCountdownActive: Bool {
        startCountdownRemaining != nil
    }

    var displayedStartCountdown: Int {
        guard let startCountdownRemaining else { return 0 }
        return max(1, Int(ceil(startCountdownRemaining)))
    }

    var startCountdownProgress: Double {
        guard let startCountdownRemaining else { return 0 }
        let countdownDuration = configuredStartCountdownDuration
        guard countdownDuration > 0 else { return 0 }
        let elapsed = countdownDuration - startCountdownRemaining
        return min(max(elapsed / countdownDuration, 0), 1)
    }

    func setSoundEnabled(_ enabled: Bool) {
        settings.soundEnabled = enabled
        persistSettings()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        settings.hapticsEnabled = enabled
        persistSettings()
    }

    func setKeepScreenAwake(_ enabled: Bool) {
        settings.keepScreenAwake = enabled
        persistSettings()
        applyIdleTimerPolicy()
    }

    func setStartCountdownDuration(_ duration: Int) {
        settings.startCountdownDuration = duration
        persistSettings()
    }

    func setDifficulty(_ difficulty: WorkoutDifficulty) {
        settings.difficulty = difficulty
        persistSettings()
    }

    var hasRemovedAds: Bool {
        settings.hasRemovedAds
    }

    var shouldShowCompletionBanner: Bool {
        settings.adsEnabled && !settings.hasRemovedAds && sessionEngine.state?.status == .completed
    }

    var completionBannerAdUnitID: String {
        adsManager.completionBannerAdUnitID
    }

    var removeAdsCTA: String {
        if hasRemovedAds {
            return "Purchased"
        }

        if let removeAdsProductPrice {
            return "Remove Ads • \(removeAdsProductPrice)"
        }

        return "Remove Ads"
    }

    func purchaseRemoveAds() async {
        guard !isStoreProcessing, !hasRemovedAds else { return }
        isStoreProcessing = true
        defer { isStoreProcessing = false }

        do {
            switch try await storeManager.purchaseRemoveAds() {
            case .success:
                alert = AppAlert(
                    title: "Remove Ads Unlocked",
                    message: "Ads have been removed from the app."
                )
            case .pending:
                alert = AppAlert(
                    title: "Purchase Pending",
                    message: "The App Store is still processing your purchase."
                )
            case .cancelled:
                break
            }
        } catch {
            alert = AppAlert(
                title: "Purchase Failed",
                message: error.localizedDescription
            )
        }
    }

    func restorePurchases() async {
        guard !isStoreProcessing else { return }
        isStoreProcessing = true
        defer { isStoreProcessing = false }

        do {
            try await storeManager.restorePurchases()

            alert = AppAlert(
                title: hasRemovedAds ? "Purchases Restored" : "Nothing to Restore",
                message: hasRemovedAds
                    ? "Your Remove Ads purchase has been restored."
                    : "No Remove Ads purchase was found for this Apple account."
            )
        } catch {
            alert = AppAlert(
                title: "Restore Failed",
                message: error.localizedDescription
            )
        }
    }

    func skipToNextStage() {
        sessionEngine.skipToNextStage(settings: settings)
        applyIdleTimerPolicy()
    }

    func finishCompletedSession() {
        sessionEngine.dismissCompletedState()
        applyIdleTimerPolicy()
    }

    func handleScenePhase(_ scenePhase: ScenePhase) {
        if scenePhase != .active {
            cancelStartCountdown()
        }
        sessionEngine.handleScenePhase(scenePhase, settings: settings)
        applyIdleTimerPolicy()
    }

    private func persistSettings() {
        storage.saveSettings(settings)
    }

    private func setHasRemovedAds(_ hasRemovedAds: Bool) {
        guard settings.hasRemovedAds != hasRemovedAds else { return }
        settings.hasRemovedAds = hasRemovedAds
        persistSettings()
    }

    private var configuredStartCountdownDuration: TimeInterval {
        TimeInterval(settings.startCountdownDuration)
    }

    private func applyIdleTimerPolicy() {
        let allowIdlePrevention = settings.keepScreenAwake && sessionEngine.isActivelyRunning
        UIApplication.shared.isIdleTimerDisabled = allowIdlePrevention
    }
}
