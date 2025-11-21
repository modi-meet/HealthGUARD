import SwiftUI
import FirebaseCore

@main
struct HealthGuardApp: App {
    @StateObject private var dataManager = DataManager()

    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // Request permissions on first launch
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
