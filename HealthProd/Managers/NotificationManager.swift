import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func handleHealthStatusChange(_ status: HealthStatus) {
        guard status != .normal else { return }
        
        // 1. Local Notification
        sendLocalNotification(for: status)
        
        // 2. External Notifications (SMS/Call)
        if status == .major || status == .critical {
            notifyEmergencyContacts(for: status)
        }
        
        // 3. Drone Dispatch
        if status == .critical {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                DroneDispatchManager.shared.triggerDroneDispatch()
            }
        }
    }
    
    private func sendLocalNotification(for status: HealthStatus) {
        let content = UNMutableNotificationContent()
        content.title = "Health Alert: \(status.rawValue.capitalized)"
        content.body = status.description
        content.sound = status == .critical ? .defaultCritical : .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func notifyEmergencyContacts(for status: HealthStatus) {
        let contacts = ContactManager.shared.getContacts(for: status)
        guard !contacts.isEmpty else { return }
        
        print("Simulating external notification to \(contacts.count) contacts for \(status) alert.")
        
        // In a real app, call backend API here
        // APIClient.shared.sendEmergencyAlert(contacts: contacts, severity: status)
    }
}
