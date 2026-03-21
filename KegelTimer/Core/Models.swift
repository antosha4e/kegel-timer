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

    static let easy = WorkoutProgram(
        name: "Pelvic Floor Routine",
        stages: [
            WorkoutStage(
                id: "hold-1",
                name: "Hold",
                subtitle: "Steady warm-up contractions to build coordination",
                totalSeconds: 21,
                squeezeSeconds: 3,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "rest-1",
                name: "Rest",
                subtitle: "Full release before the next round",
                totalSeconds: 8,
                squeezeSeconds: 0,
                relaxSeconds: 8
            ),
            WorkoutStage(
                id: "pulse-1",
                name: "Pulse",
                subtitle: "Shorter efforts focused on control",
                totalSeconds: 22,
                squeezeSeconds: 2,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "rest-2",
                name: "Rest",
                subtitle: "Take a longer reset before the finish",
                totalSeconds: 8,
                squeezeSeconds: 0,
                relaxSeconds: 8
            ),
            WorkoutStage(
                id: "hold-2",
                name: "Hold",
                subtitle: "Finish with clean, even squeezes",
                totalSeconds: 21,
                squeezeSeconds: 3,
                relaxSeconds: 3
            )
        ]
    )

    static let intermediate = WorkoutProgram(
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
                id: "rest-1",
                name: "Rest",
                subtitle: "Six seconds of full release before the next effort",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
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

    static let hard = WorkoutProgram(
        name: "Pelvic Floor Routine",
        stages: [
            WorkoutStage(
                id: "hold-1",
                name: "Hold",
                subtitle: "Longer contractions to challenge endurance",
                totalSeconds: 32,
                squeezeSeconds: 4,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "rest-1",
                name: "Rest",
                subtitle: "Reset fully before the next effort",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
            ),
            WorkoutStage(
                id: "power-1",
                name: "Power",
                subtitle: "Quick, repeated contractions at a higher pace",
                totalSeconds: 33,
                squeezeSeconds: 3,
                relaxSeconds: 2
            ),
            WorkoutStage(
                id: "rest-2",
                name: "Rest",
                subtitle: "Short recovery before the final push",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
            ),
            WorkoutStage(
                id: "hold-2",
                name: "Hold",
                subtitle: "Stay steady through the toughest squeeze block",
                totalSeconds: 32,
                squeezeSeconds: 4,
                relaxSeconds: 3
            ),
            WorkoutStage(
                id: "rest-3",
                name: "Rest",
                subtitle: "Short recovery before the final push",
                totalSeconds: 6,
                squeezeSeconds: 0,
                relaxSeconds: 6
            ),
            WorkoutStage(
                id: "power-2",
                name: "Power",
                subtitle: "Finish with fast, controlled pulses",
                totalSeconds: 33,
                squeezeSeconds: 3,
                relaxSeconds: 2
            )
        ]
    )

    static let `default` = intermediate
}

enum WorkoutDifficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case intermediate
    case hard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .intermediate:
            return "Intermediate"
        case .hard:
            return "Hard"
        }
    }

    var subtitle: String {
        switch self {
        case .easy:
            return "Shorter holds with more recovery"
        case .intermediate:
            return "Balanced pacing for most sessions"
        case .hard:
            return "Longer holds and tighter recovery"
        }
    }

    var program: WorkoutProgram {
        switch self {
        case .easy:
            return .easy
        case .intermediate:
            return .intermediate
        case .hard:
            return .hard
        }
    }
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
    var startCountdownDuration: Int
    var difficulty: WorkoutDifficulty
    var adsEnabled: Bool
    var hasRemovedAds: Bool

    private enum CodingKeys: String, CodingKey {
        case soundEnabled
        case hapticsEnabled
        case keepScreenAwake
        case startCountdownDuration
        case difficulty
        case adsEnabled
        case hasRemovedAds
    }

    init(
        soundEnabled: Bool,
        hapticsEnabled: Bool,
        keepScreenAwake: Bool,
        startCountdownDuration: Int,
        difficulty: WorkoutDifficulty,
        adsEnabled: Bool,
        hasRemovedAds: Bool
    ) {
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.keepScreenAwake = keepScreenAwake
        self.startCountdownDuration = startCountdownDuration
        self.difficulty = difficulty
        self.adsEnabled = adsEnabled
        self.hasRemovedAds = hasRemovedAds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        keepScreenAwake = try container.decodeIfPresent(Bool.self, forKey: .keepScreenAwake) ?? true
        startCountdownDuration = try container.decodeIfPresent(Int.self, forKey: .startCountdownDuration) ?? 3
        difficulty = try container.decodeIfPresent(WorkoutDifficulty.self, forKey: .difficulty) ?? .intermediate
        adsEnabled = try container.decodeIfPresent(Bool.self, forKey: .adsEnabled) ?? true
        hasRemovedAds = try container.decodeIfPresent(Bool.self, forKey: .hasRemovedAds) ?? false
    }

    static let `default` = AppSettings(
        soundEnabled: true,
        hapticsEnabled: true,
        keepScreenAwake: true,
        startCountdownDuration: 3,
        difficulty: .intermediate,
        adsEnabled: true,
        hasRemovedAds: false
    )
}
