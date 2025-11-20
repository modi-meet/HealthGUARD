import Foundation

class MockDataGenerator {
    static let shared = MockDataGenerator()
    
    private var timer: Timer?
    
    func startSimulatingVitals() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.simulateVitalUpdate()
        }
    }
    
    func stopSimulating() {
        timer?.invalidate()
        timer = nil
    }
    
    private func simulateVitalUpdate() {
        // Simulate random fluctuations
        let hr = Double.random(in: 60...100)
        let spo2 = Double.random(in: 95...100)
        
        // Inject into HealthKitManager (We would need to make properties settable or have a 'simulate' method)
        // For now, we can just print or manually trigger if we modified HealthKitManager to accept mock data.
        // Since HealthKitManager reads from HK, we can't easily inject without a protocol.
        // However, for the hackathon, we might want a "Demo Mode" button in Settings.
    }
    
    // Helper to trigger a critical event
    func triggerCriticalEvent() {
        // This would ideally update the HealthAnalyzer directly or mock the HK data
        // For simplicity, let's assume we can force the state in HealthAnalyzer if we made it settable
        // or just rely on the user using the Debug/Settings to trigger it.
    }
}
