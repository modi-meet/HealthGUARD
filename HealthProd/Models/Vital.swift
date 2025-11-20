import Foundation

struct Vital: Identifiable, Codable {
    let id: UUID
    let type: VitalType
    let value: Double
    let unit: String
    let date: Date
    
    init(type: VitalType, value: Double, unit: String, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.value = value
        self.unit = unit
        self.date = date
    }
}

enum VitalType: String, Codable {
    case heartRate
    case spO2
    case bloodPressureSystolic
    case bloodPressureDiastolic
}
