import AudioToolbox
import UIKit

final class CueManager {
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    func prepare() {
        feedbackGenerator.prepare()
    }

    func playTransition(for phase: SessionPhaseKind, settings: AppSettings, isForeground: Bool) {
        if settings.hapticsEnabled && isForeground {
            switch phase {
            case .squeeze:
                feedbackGenerator.notificationOccurred(.success)
            case .relax:
                feedbackGenerator.notificationOccurred(.warning)
            }
        }

        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1113)
        }
    }

    func playCompletion(settings: AppSettings, isForeground: Bool) {
        if settings.hapticsEnabled && isForeground {
            feedbackGenerator.notificationOccurred(.success)
        }

        if settings.soundEnabled {
            AudioServicesPlaySystemSound(1025)
        }
    }
}
