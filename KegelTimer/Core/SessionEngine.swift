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

    func start(program: WorkoutProgram, settings: AppSettings) {
        snapshot = SessionSnapshot(
            program: program,
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
        let totalDuration = snapshot.program.totalDuration
        let previousState = state

        guard elapsed < totalDuration else {
            let finalStage = snapshot.program.stages.last ?? WorkoutProgram.default.stages[0]
            state = SessionState(
                program: snapshot.program,
                stage: finalStage,
                currentStageIndex: snapshot.program.stages.count,
                totalStages: snapshot.program.stages.count,
                status: .completed,
                phase: .relax,
                stageRemaining: 0,
                phaseRemaining: 0,
                secondsRemainingInStage: 0,
                secondsRemainingInPhase: 0,
                phaseDuration: finalStage.relaxSeconds,
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

        guard let stageResolution = resolveStage(for: elapsed, in: snapshot.program) else {
            state = nil
            self.snapshot = nil
            stopTimer()
            endBackgroundTask()
            persistSnapshot()
            return
        }

        let stage = stageResolution.stage
        let stageElapsed = stageResolution.elapsedWithinStage
        let stageRemaining = max(0, stage.totalDuration - stageElapsed)
        let cycleDuration = TimeInterval(stage.squeezeSeconds + stage.relaxSeconds)
        let cyclePosition = stageElapsed.truncatingRemainder(dividingBy: cycleDuration)

        let phase: SessionPhaseKind
        let phaseDuration: Int
        let secondsRemaining: Int
        let phaseRemaining: TimeInterval

        if cyclePosition < TimeInterval(stage.squeezeSeconds) {
            phase = .squeeze
            phaseDuration = stage.squeezeSeconds
            phaseRemaining = max(0, min(TimeInterval(stage.squeezeSeconds) - cyclePosition, stageRemaining))
            secondsRemaining = max(0, Int(ceil(phaseRemaining)))
        } else {
            phase = .relax
            phaseDuration = stage.relaxSeconds
            phaseRemaining = max(0, min(cycleDuration - cyclePosition, stageRemaining))
            secondsRemaining = max(0, Int(ceil(phaseRemaining)))
        }

        let newState = SessionState(
            program: snapshot.program,
            stage: stage,
            currentStageIndex: stageResolution.stageIndex + 1,
            totalStages: snapshot.program.stages.count,
            status: snapshot.pausedAt == nil ? .running : .paused,
            phase: phase,
            stageRemaining: stageRemaining,
            phaseRemaining: phaseRemaining,
            secondsRemainingInStage: Int(ceil(stageRemaining)),
            secondsRemainingInPhase: secondsRemaining,
            phaseDuration: phaseDuration,
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

    private func resolveStage(for elapsed: TimeInterval, in program: WorkoutProgram) -> (stage: WorkoutStage, stageIndex: Int, elapsedWithinStage: TimeInterval)? {
        var consumed: TimeInterval = 0

        for (index, stage) in program.stages.enumerated() {
            let nextBoundary = consumed + stage.totalDuration
            if elapsed < nextBoundary {
                return (stage, index, elapsed - consumed)
            }
            consumed = nextBoundary
        }

        return nil
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
