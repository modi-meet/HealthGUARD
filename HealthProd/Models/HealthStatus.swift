import Foundation
import SwiftUI
import Combine

enum HealthStatus: String, Codable, CaseIterable {
    case light
    case major
    case critical
    case normal
    
    var color: Color {
        switch self {
        case .light: return .yellow
        case .major: return .orange
        case .critical: return .red
        case .normal: return .green
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Light Alert: Minor deviation detected."
        case .major: return "Major Alert: Significant health concern."
        case .critical: return "CRITICAL ALERT: Emergency situation detected!"
        case .normal: return "All vitals are within normal range."
        }
    }
    
    var severityScore: Int {
        switch self {
        case .normal: return 0
        case .light: return 30
        case .major: return 60
        case .critical: return 100
        }
    }
}
