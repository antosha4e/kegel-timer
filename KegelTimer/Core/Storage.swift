import Foundation

struct AppStorage {
    private enum Key {
        static let settings = "settings"
        static let customRoutine = "customRoutine"
        static let activeSnapshot = "activeSnapshot"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSettings() -> AppSettings {
        loadValue(forKey: Key.settings, defaultValue: .default)
    }

    func saveSettings(_ settings: AppSettings) {
        saveValue(settings, forKey: Key.settings)
    }

    func loadCustomRoutine() -> CustomRoutine {
        loadValue(forKey: Key.customRoutine, defaultValue: .default)
    }

    func saveCustomRoutine(_ routine: CustomRoutine) {
        saveValue(routine, forKey: Key.customRoutine)
    }

    func loadActiveSnapshot() -> SessionSnapshot? {
        guard let data = userDefaults.data(forKey: Key.activeSnapshot) else { return nil }
        return try? decoder.decode(SessionSnapshot.self, from: data)
    }

    func saveActiveSnapshot(_ snapshot: SessionSnapshot?) {
        guard let snapshot else {
            userDefaults.removeObject(forKey: Key.activeSnapshot)
            return
        }

        guard let data = try? encoder.encode(snapshot) else { return }
        userDefaults.set(data, forKey: Key.activeSnapshot)
    }

    private func loadValue<T: Codable>(forKey key: String, defaultValue: T) -> T {
        guard let data = userDefaults.data(forKey: key),
              let value = try? decoder.decode(T.self, from: data) else {
            return defaultValue
        }
        return value
    }

    private func saveValue<T: Codable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        userDefaults.set(data, forKey: key)
    }
}
