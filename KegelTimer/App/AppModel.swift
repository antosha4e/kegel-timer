import Combine
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published private(set) var customRoutine: CustomRoutine

    let sessionEngine: SessionEngine
    let presets: [WorkoutPreset]

    private let storage: AppStorage
    private let cueManager: CueManager
    private var cancellables = Set<AnyCancellable>()
    private var hasRestored = false

    init(
        storage: AppStorage = AppStorage(),
        cueManager: CueManager = CueManager(),
        presets: [WorkoutPreset] = WorkoutPreset.defaults
    ) {
        self.storage = storage
        self.cueManager = cueManager
        self.presets = presets
        self.settings = storage.loadSettings()
        self.customRoutine = storage.loadCustomRoutine()
        self.sessionEngine = SessionEngine(cueManager: cueManager)

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

    func restore() {
        guard !hasRestored else { return }
        hasRestored = true
        sessionEngine.restore(from: storage.loadActiveSnapshot(), settings: settings)
        applyIdleTimerPolicy()
    }

    func startPreset(_ preset: WorkoutPreset) {
        sessionEngine.start(routine: preset.asRoutine, settings: settings)
        applyIdleTimerPolicy()
    }

    func startCustomRoutine() {
        sessionEngine.start(routine: customRoutine.asSessionRoutine, settings: settings)
        applyIdleTimerPolicy()
    }

    func saveCustomRoutine(_ routine: CustomRoutine) {
        customRoutine = routine.normalized
        storage.saveCustomRoutine(customRoutine)
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

    func finishCompletedSession() {
        sessionEngine.dismissCompletedState()
        applyIdleTimerPolicy()
    }

    func handleScenePhase(_ scenePhase: ScenePhase) {
        sessionEngine.handleScenePhase(scenePhase, settings: settings)
        applyIdleTimerPolicy()
    }

    private func persistSettings() {
        storage.saveSettings(settings)
    }

    private func applyIdleTimerPolicy() {
        let allowIdlePrevention = settings.keepScreenAwake && sessionEngine.isActivelyRunning
        UIApplication.shared.isIdleTimerDisabled = allowIdlePrevention
    }
}
