import SwiftUI

@main
struct HealthGuardApp: App {
    // Initialize Managers on launch
    init() {
        _ = HealthKitManager.shared
        _ = NotificationManager.shared
        _ = DataManager.shared
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
