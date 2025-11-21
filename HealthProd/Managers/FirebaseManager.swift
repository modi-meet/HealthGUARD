import Foundation
import FirebaseDatabase

class FirebaseManager {
    static let shared = FirebaseManager()
    private let databaseRef = Database.database().reference()

    private init() {}

    func sendEmergencyData(data: EmergencyData) {
        let emergenciesRef = databaseRef.child("emergencies").childByAutoId()
        emergenciesRef.setValue(try? data.asDictionary()) { error, _ in
            if let error = error {
                print("Error sending emergency data: \(error.localizedDescription)")
            } else {
                print("Emergency data sent successfully.")
            }
        }
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
