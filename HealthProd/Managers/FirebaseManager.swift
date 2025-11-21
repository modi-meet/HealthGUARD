import Foundation
import UIKit

class FirebaseManager {
    static let shared = FirebaseManager()
    
    // Firebase Realtime Database URL - loaded from Config.swift (not committed to git)
    private let firebaseURL = Config.firebaseURL
    
    private init() {}
    
    /// Send critical alert to Firebase with location data
    func sendCriticalAlert(
        userId: String,
        heartRate: Double,
        spO2: Double,
        bloodPressure: String,
        latitude: Double,
        longitude: Double
    ) {
        let timestamp = Date().timeIntervalSince1970
        let alertId = UUID().uuidString
        
        // Construct Firebase payload
        let payload: [String: Any] = [
            "userId": userId,
            "timestamp": timestamp,
            "severity": "critical",
            "location": [
                "latitude": latitude,
                "longitude": longitude
            ],
            "vitals": [
                "heartRate": heartRate,
                "spO2": spO2,
                "bloodPressure": bloodPressure
            ],
            "droneDispatched": true,
            "droneETA": 480, // 8 minutes in seconds
            "status": "active"
        ]
        
        // Convert to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("❌ Failed to serialize Firebase payload")
            return
        }
        
        // Construct Firebase REST API URL
        let urlString = "\(firebaseURL)/emergencies/\(alertId).json"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid Firebase URL")
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Firebase send error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Alert sent to Firebase successfully")
                    print("📍 Location: (\(latitude), \(longitude))")
                    print("🆔 Alert ID: \(alertId)")
                } else {
                    print("❌ Firebase returned status code: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
        
        // Log the payload for debugging
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Firebase payload: \(jsonString)")
        }
    }
}
