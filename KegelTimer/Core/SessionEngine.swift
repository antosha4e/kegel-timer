import SwiftUI
import UIKit

@MainActor
final class SessionEngine: ObservableObject {
    @Published private(set) var state: SessionState?

    var onSnapshotChange: ((SessionSnapshot?) -> Void)?

    var isActivelyRunning: Bool {
        state?.status == .running
    }

    private let cueManager: CueManager
    private var snapshot: SessionSnapshot?
    private var timer: Timer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init(cueManager: CueManager) {
        self.cueManager = cueManager
    }

    func start(routine: SessionRoutine, settings: AppSettings) {
        snapshot = SessionSnapshot(
            routine: routine,
            startedAt: Date(),
            accumulatedPauseInterval: 0,
            pausedAt: nil
        )
        cueManager.prepare()
        updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
        startTimer(settings: settings)
        persistSnapshot()
    }

    func pause(settings: AppSettings) {
        guard var current = snapshot, current.pausedAt == nil else { return }
        current.pausedAt = Date()
        snapshot = current
        stopTimer()
        updateState(using: current.pausedAt ?? Date(), settings: settings, shouldNotifyPhaseTransition: false)
        persistSnapshot()
    }

    func resume(settings: AppSettings) {
        guard var current = snapshot, let pausedAt = current.pausedAt else { return }
        current.accumulatedPauseInterval += Date().timeIntervalSince(pausedAt)
        current.pausedAt = nil
        snapshot = current
        cueManager.prepare()
        updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
        startTimer(settings: settings)
        persistSnapshot()
    }

    func cancel() {
        snapshot = nil
        state = nil
        stopTimer()
        endBackgroundTask()
        persistSnapshot()
    }

    func dismissCompletedState() {
        state = nil
        endBackgroundTask()
    }

    func restore(from snapshot: SessionSnapshot?, settings: AppSettings) {
        self.snapshot = snapshot
        guard snapshot != nil else {
            state = nil
            stopTimer()
            persistSnapshot()
            return
        }

        updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
        if self.snapshot != nil, state?.status == .running {
            startTimer(settings: settings)
        } else {
            stopTimer()
        }
    }

    func handleScenePhase(_ scenePhase: ScenePhase, settings: AppSettings) {
        switch scenePhase {
        case .active:
            cueManager.prepare()
            updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
            if snapshot != nil, state?.status == .running {
                startTimer(settings: settings)
            }
            endBackgroundTask()
        case .inactive:
            updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
        case .background:
            beginBackgroundTaskIfNeeded()
            updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: false)
            persistSnapshot()
        @unknown default:
            break
        }
    }

    private func startTimer(settings: AppSettings) {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.updateState(using: Date(), settings: settings, shouldNotifyPhaseTransition: true)
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateState(using now: Date, settings: AppSettings, shouldNotifyPhaseTransition: Bool) {
        guard let snapshot else {
            state = nil
            persistSnapshot()
            return
        }

        let effectiveNow = snapshot.pausedAt ?? now
        let elapsed = max(0, effectiveNow.timeIntervalSince(snapshot.startedAt) - snapshot.accumulatedPauseInterval)
        let totalDuration = snapshot.routine.totalDuration
        let previousState = state

        guard elapsed < totalDuration else {
            state = SessionState(
                routine: snapshot.routine,
                status: .completed,
                phase: .relax,
                secondsRemainingInPhase: 0,
                phaseDuration: snapshot.routine.relaxSeconds,
                currentRepetition: snapshot.routine.repetitions,
                totalRepetitions: snapshot.routine.repetitions,
                elapsedSeconds: Int(totalDuration.rounded()),
                totalDuration: Int(totalDuration.rounded())
            )
            self.snapshot = nil
            stopTimer()
            endBackgroundTask()
            persistSnapshot()
            if previousState?.status != .completed {
                cueManager.playCompletion(settings: settings, isForeground: UIApplication.shared.applicationState == .active)
            }
            return
        }

        let cycleDuration = TimeInterval(snapshot.routine.squeezeSeconds + snapshot.routine.relaxSeconds)
        let cyclePosition = elapsed.truncatingRemainder(dividingBy: cycleDuration)
        let repetitionIndex = min(snapshot.routine.repetitions, Int(elapsed / cycleDuration) + 1)

        let phase: SessionPhaseKind
        let phaseDuration: Int
        let secondsRemaining: Int

        if cyclePosition < TimeInterval(snapshot.routine.squeezeSeconds) {
            phase = .squeeze
            phaseDuration = snapshot.routine.squeezeSeconds
            secondsRemaining = max(0, Int(ceil(TimeInterval(snapshot.routine.squeezeSeconds) - cyclePosition)))
        } else {
            phase = .relax
            phaseDuration = snapshot.routine.relaxSeconds
            secondsRemaining = max(0, Int(ceil(cycleDuration - cyclePosition)))
        }

        let newState = SessionState(
            routine: snapshot.routine,
            status: snapshot.pausedAt == nil ? .running : .paused,
            phase: phase,
            secondsRemainingInPhase: secondsRemaining,
            phaseDuration: phaseDuration,
            currentRepetition: repetitionIndex,
            totalRepetitions: snapshot.routine.repetitions,
            elapsedSeconds: Int(elapsed.rounded(.down)),
            totalDuration: Int(totalDuration.rounded())
        )

        state = newState

        if shouldNotifyPhaseTransition,
           let previousState,
           previousState.status == .running,
           previousState.phase != newState.phase {
            cueManager.playTransition(for: newState.phase, settings: settings, isForeground: UIApplication.shared.applicationState == .active)
        }

        persistSnapshot()
    }

    private func persistSnapshot() {
        onSnapshotChange?(snapshot)
    }

    private func beginBackgroundTaskIfNeeded() {
        guard backgroundTaskID == .invalid, snapshot != nil else { return }
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "ActiveKegelSession") { [weak self] in
            Task { @MainActor in
                self?.endBackgroundTask()
            }
        }
    }

    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}
