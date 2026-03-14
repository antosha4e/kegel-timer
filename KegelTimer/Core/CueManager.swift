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

    }

    func playCompletion(settings: AppSettings, isForeground: Bool) {
        if settings.hapticsEnabled && isForeground {
            feedbackGenerator.notificationOccurred(.success)
        }
    }
}
