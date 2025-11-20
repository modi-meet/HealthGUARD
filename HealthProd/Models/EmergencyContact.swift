import Foundation

struct EmergencyContact: Identifiable, Codable {
    var id: UUID
    var name: String
    var email: String
    var phoneNumber: String
    var notificationThreshold: HealthStatus // .light, .major, .critical
    
    init(id: UUID = UUID(), name: String, email: String, phoneNumber: String, notificationThreshold: HealthStatus) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.notificationThreshold = notificationThreshold
    }
}
