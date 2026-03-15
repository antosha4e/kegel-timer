import Foundation

enum SessionPhaseKind: String, Codable, CaseIterable {
    case squeeze
    case relax

    var title: String {
        switch self {
        case .squeeze:
            return "Squeeze"
        case .relax:
            return "Relax"
        }
    }

    var coachingLine: String {
        switch self {
        case .squeeze:
            return "Lift and hold with steady breathing."
        case .relax:
            return "Release fully before the next repetition."
        }
    }
}

enum SessionStatus: String, Codable {
    case running
    case paused
    case completed
    case cancelled
}

struct WorkoutStage: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let totalSeconds: Int
    let squeezeSeconds: Int
    let relaxSeconds: Int

    var totalDuration: TimeInterval {
        TimeInterval(totalSeconds)
    }
}

struct WorkoutProgram: Codable, Equatable {
    let name: String
    let stages: [WorkoutStage]

    var totalDuration: TimeInterval {
        stages.reduce(0) { $0 + $1.totalDuration }
    }

    static let `default` = WorkoutProgram(
        name: "Pelvic Floor Routine",
        stages: [
            WorkoutStage(
                id: "hold-1",
                name: "Hold",
                subtitle: "Quick contractions to wake up the pattern",
                totalSeconds: 25,
                squeezeSeconds: 4,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "rest-1",
                name: "Rest",
                subtitle: "Six seconds of full release before the next effort",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
            ),
            WorkoutStage(
                id: "trembling-1",
                name: "Trembling",
                subtitle: "Longer squeeze intervals for endurance",
                totalSeconds: 30,
                squeezeSeconds: 2,
                relaxSeconds: 2
            ),
            WorkoutStage(
                id: "rest-2",
                name: "Rest",
                subtitle: "Six seconds of full release before the final push",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
            ),
            WorkoutStage(
                id: "hold-2",
                name: "Hold",
                subtitle: "Return to crisp controlled contractions",
                totalSeconds: 25,
                squeezeSeconds: 4,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "trembling-2",
                name: "Trembling",
                subtitle: "Finish with sustained effort and control",
                totalSeconds: 30,
                squeezeSeconds: 2,
                relaxSeconds: 2
            )
        ]
    )
}

struct SessionState: Equatable {
    let program: WorkoutProgram
    let stage: WorkoutStage
    let currentStageIndex: Int
    let totalStages: Int
    let status: SessionStatus
    let phase: SessionPhaseKind
    let stageRemaining: TimeInterval
    let phaseRemaining: TimeInterval
    let secondsRemainingInStage: Int
    let secondsRemainingInPhase: Int
    let phaseDuration: Int
    let elapsedSeconds: Int
    let totalDuration: Int

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalDuration)
    }

    var phaseProgress: Double {
        guard phaseDuration > 0 else { return 0 }
        return 1 - (phaseRemaining / Double(phaseDuration))
    }

    var stageProgress: Double {
        guard stage.totalSeconds > 0 else { return 0 }
        return 1 - (stageRemaining / Double(stage.totalSeconds))
    }

    var isPaused: Bool {
        status == .paused
    }
}

struct SessionSnapshot: Codable, Equatable {
    var program: WorkoutProgram
    var startedAt: Date
    var accumulatedPauseInterval: TimeInterval
    var pausedAt: Date?
}

struct AppSettings: Codable, Equatable {
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var keepScreenAwake: Bool

    static let `default` = AppSettings(
        soundEnabled: true,
        hapticsEnabled: true,
        keepScreenAwake: true
    )
}
