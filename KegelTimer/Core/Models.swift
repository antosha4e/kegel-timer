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

struct WorkoutPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let squeezeSeconds: Int
    let relaxSeconds: Int
    let repetitions: Int

    var asRoutine: SessionRoutine {
        SessionRoutine(
            name: name,
            squeezeSeconds: squeezeSeconds,
            relaxSeconds: relaxSeconds,
            repetitions: repetitions
        )
    }

    static let defaults: [WorkoutPreset] = [
        WorkoutPreset(
            id: "short-holding",
            name: "Short Holding",
            subtitle: "Quick contractions with easy pacing",
            squeezeSeconds: 4,
            relaxSeconds: 6,
            repetitions: 10
        ),
        WorkoutPreset(
            id: "rest",
            name: "Rest",
            subtitle: "Balanced rhythm with longer release",
            squeezeSeconds: 6,
            relaxSeconds: 8,
            repetitions: 12
        ),
        WorkoutPreset(
            id: "trembling",
            name: "Trembling",
            subtitle: "Longer squeeze intervals for endurance",
            squeezeSeconds: 8,
            relaxSeconds: 8,
            repetitions: 10
        )
    ]
}

struct SessionRoutine: Codable, Equatable {
    let name: String
    let squeezeSeconds: Int
    let relaxSeconds: Int
    let repetitions: Int

    var totalDuration: TimeInterval {
        TimeInterval(repetitions * (squeezeSeconds + relaxSeconds))
    }
}

struct SessionState: Equatable {
    let routine: SessionRoutine
    let status: SessionStatus
    let phase: SessionPhaseKind
    let secondsRemainingInPhase: Int
    let phaseDuration: Int
    let currentRepetition: Int
    let totalRepetitions: Int
    let elapsedSeconds: Int
    let totalDuration: Int

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(totalDuration)
    }

    var phaseProgress: Double {
        guard phaseDuration > 0 else { return 0 }
        return 1 - (Double(secondsRemainingInPhase) / Double(phaseDuration))
    }

    var isPaused: Bool {
        status == .paused
    }

    var progressText: String {
        "Rep \(currentRepetition) of \(totalRepetitions)"
    }
}

struct SessionSnapshot: Codable, Equatable {
    var routine: SessionRoutine
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
