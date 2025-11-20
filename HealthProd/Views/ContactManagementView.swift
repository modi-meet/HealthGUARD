import SwiftUI

struct ContactManagementView: View {
    @StateObject private var contactManager = ContactManager.shared
    @State private var showAddSheet = false
    
    var body: some View {
        List {
            ForEach(contactManager.contacts) { contact in
                VStack(alignment: .leading) {
                    Text(contact.name)
                        .font(.headline)
                    Text(contact.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Notify on: \(contact.notificationThreshold.rawValue.capitalized)")
                        .font(.caption)
                        .padding(4)
                        .background(contact.notificationThreshold.color.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .onDelete(perform: contactManager.removeContact)
        }
        .navigationTitle("Emergency Contacts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddContactView(isPresented: $showAddSheet)
        }
    }
}

struct AddContactView: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var threshold: HealthStatus = .major
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("Notification Settings")) {
                    Picker("Notify When Status Is", selection: $threshold) {
                        Text("Light (Minor)").tag(HealthStatus.light)
                        Text("Major (Serious)").tag(HealthStatus.major)
                        Text("Critical (Emergency)").tag(HealthStatus.critical)
                    }
                }
            }
            .navigationTitle("Add Contact")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") {
                    let newContact = EmergencyContact(name: name, email: email, phoneNumber: phone, notificationThreshold: threshold)
                    ContactManager.shared.addContact(newContact)
                    isPresented = false
                }
                .disabled(name.isEmpty || phone.isEmpty)
            )
        }
    }
}
