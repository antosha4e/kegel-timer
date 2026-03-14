import SwiftUI

@main
struct KegelTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
                .environmentObject(appModel.sessionEngine)
                .task {
                    appModel.restore()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    appModel.handleScenePhase(newPhase)
                }
        }
    }
}
