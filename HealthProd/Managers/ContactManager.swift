import SwiftUI
import Foundation
import Combine

class ContactManager: ObservableObject {
    static let shared = ContactManager()
    
    @Published var contacts: [EmergencyContact] = []
    
    private let saveKey = "EmergencyContacts"
    
    init() {
        loadContacts()
    }
    
    func addContact(_ contact: EmergencyContact) {
        contacts.append(contact)
        saveContacts()
    }
    
    func removeContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveContacts()
    }
    
    func updateContact(_ contact: EmergencyContact) {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
            saveContacts()
        }
    }
    
    private func saveContacts() {
        do {
            let data = try JSONEncoder().encode(contacts)
            // In a real app, use Keychain. For prototype, UserDefaults is acceptable but we'll simulate security.
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Failed to save contacts: \(error.localizedDescription)")
        }
    }
    
    private func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            contacts = try JSONDecoder().decode([EmergencyContact].self, from: data)
        } catch {
            print("Failed to load contacts: \(error.localizedDescription)")
        }
    }
    
    func getContacts(for severity: HealthStatus) -> [EmergencyContact] {
        return contacts.filter { contact in
            // Notify if contact's threshold is equal to or less severe than the current event
            // e.g. if threshold is Light, notify on Light, Major, Critical
            // e.g. if threshold is Critical, notify only on Critical
            return severity.severityScore >= contact.notificationThreshold.severityScore
        }
    }
}
