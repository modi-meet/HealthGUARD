import Foundation
import FirebaseDatabase

struct EmergencyData: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: TimeInterval
    let userId: String
    let vitals: [String: Double]
}
