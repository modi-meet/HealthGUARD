import Foundation
import Combine
import UIKit
internal import _LocationEssentials



class HealthAnalyzer: ObservableObject {
    static let shared = HealthAnalyzer()
    
    @Published var currentStatus: HealthStatus = .normal
    @Published var statusMessage: String = "Monitoring..."
    
    private var cancellables = Set<AnyCancellable>()
    private let healthKitManager = HealthKitManager.shared
    
    // Configurable Thresholds
    private let heartRateCriticalHigh: Double = 150
    private let heartRateCriticalLow: Double = 30
    private let heartRateMajorHigh: Double = 120
    private let heartRateMajorLow: Double = 40
    private let heartRateLightHigh: Double = 100
    private let heartRateLightLow: Double = 60
    
    private let spO2Critical: Double = 85
    private let spO2Major: Double = 89
    private let spO2Light: Double = 95
    
    // Cooldown to prevent spamming alerts
    private var lastAlertTime: Date?
    private let alertCooldown: TimeInterval = 300 // 5 minutes
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Combine latest values from HealthKitManager
        Publishers.CombineLatest(healthKitManager.$currentHeartRate, healthKitManager.$currentSpO2)
            .sink { [weak self] (hr, spo2) in
                self?.analyzeVitals(heartRate: hr, spO2: spo2)
            }
            .store(in: &cancellables)
    }
    
    private func analyzeVitals(heartRate: Double, spO2: Double) {
        // Skip analysis if data is invalid/empty (0 is default init)
        guard heartRate > 0 || spO2 > 0 else { return }
        
        var newStatus: HealthStatus = .normal
        
        // Check Critical
        if (heartRate > heartRateCriticalHigh || (heartRate < heartRateCriticalLow && heartRate > 0)) || (spO2 < spO2Critical && spO2 > 0) {
            newStatus = .critical
        }
        // Check Major
        else if (heartRate > heartRateMajorHigh || (heartRate < heartRateMajorLow && heartRate > 0)) || (spO2 < spO2Major && spO2 > 0) {
            newStatus = .major
        }
        // Check Light
        else if (heartRate > heartRateLightHigh || (heartRate < heartRateLightLow && heartRate > 0)) || (spO2 < spO2Light && spO2 > 0) {
            newStatus = .light
        }
        
        // ALWAYS Save to CoreData if there is any alert level (Light, Major, Critical)
        if newStatus != .normal {
             saveAlertToHistory(severity: newStatus, heartRate: heartRate, spO2: spO2, bloodPressure: "120/80") // Placeholder BP
        }
        
        // Update status if changed or if it's a serious alert and cooldown passed
        if newStatus != currentStatus {
            // If upgrading to a higher severity, update immediately
            if newStatus.severityScore > currentStatus.severityScore {
                updateStatus(newStatus)
            } 
            // If downgrading, maybe add a delay or hysteresis (simplified here)
            else {
                updateStatus(newStatus)
            }
        } else if newStatus == .major || newStatus == .critical {
            // Re-trigger if cooldown passed
            if let lastTime = lastAlertTime, Date().timeIntervalSince(lastTime) > alertCooldown {
                updateStatus(newStatus)
            }
        }
    }
    
    private func updateStatus(_ status: HealthStatus) {
        DispatchQueue.main.async {
            self.currentStatus = status
            self.statusMessage = status.description
            
            if status == .major || status == .critical {
                self.lastAlertTime = Date()
                // Notify NotificationManager (to be implemented)
                NotificationManager.shared.handleHealthStatusChange(status)
            }
        }
    }
    
    func saveAlertToHistory(severity: HealthStatus, heartRate: Double, spO2: Double, bloodPressure: String) {
        DataManager.shared.saveAlert(
            severity: severity.rawValue,
            heartRate: heartRate,
            spO2: spO2,
            bloodPressure: bloodPressure,
            latitude: LocationManager.shared.currentLocation?.coordinate.latitude ?? 0.0,
            longitude: LocationManager.shared.currentLocation?.coordinate.longitude ?? 0.0,
            droneDispatched: severity == .critical
        )
    }
    
    // Helper for testing - triggers critical alert with location capture
    func triggerCriticalAlert(heartRate: Double, spO2: Double, bloodPressure: String) {
        print("🚨 Critical alert triggered - capturing location...")
        
        // Step 1: Request current location (async with 5-second timeout)
        LocationManager.shared.requestCurrentLocation { [weak self] location in
            guard let self = self else { return }
            
            let latitude = location?.coordinate.latitude ?? 0.0
            let longitude = location?.coordinate.longitude ?? 0.0
            
            if location != nil {
                print("✅ Location captured: (\(latitude), \(longitude))")
            } else {
                print("⚠️ Location unavailable, using fallback (0.0, 0.0)")
            }
            
            // Step 2: Save to CoreData
            DataManager.shared.saveAlert(
                severity: "critical",
                heartRate: heartRate,
                spO2: spO2,
                bloodPressure: bloodPressure,
                latitude: latitude,
                longitude: longitude,
                droneDispatched: true
            )
            
            // Step 3: Send to Firebase
            let userId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            FirebaseManager.shared.sendCriticalAlert(
                userId: userId,
                heartRate: heartRate,
                spO2: spO2,
                bloodPressure: bloodPressure,
                latitude: latitude,
                longitude: longitude
            )
            
            // Step 4: Update UI status on main thread
            DispatchQueue.main.async {
                self.updateStatus(.critical)
            }
        }
    }
}
